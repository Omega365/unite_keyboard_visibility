import 'dart:async';

import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unite_keyboard_visibility/src/generated/messages.g.dart';
import 'package:unite_keyboard_visibility/src/platform/android/android_errors.dart';
import 'package:unite_keyboard_visibility/src/platform/unite_keyboard_visibility_platform_interface.dart';
import 'package:unite_keyboard_visibility/src/states/android_keyboard_state.dart';
import 'package:unite_keyboard_visibility/unite_keyboard_visibility.dart';

class UniteKeyboardVisibilityAndroid extends UniteKeyboardVisibilityPlatform {
  /// Unnamed constructor for [UniteKeyboardVisibilityPlatform] to use.
  @protected
  UniteKeyboardVisibilityAndroid() {
    _resultTransformer = _KeyboardVisibilityStatusTransformer(flutterApi);
  }

  /// The Flutter API for receiving events from the native Android code.
  final flutterApi = _AndroidKeyboardFlutterApiHandler();

  // The host API for communicating with the native Android code.
  final _hostApi = AndroidKeyboardVisibilityHostApi();

  late final _KeyboardVisibilityStatusTransformer _resultTransformer;

  @override
  Future<void> close() async {
    await _resultTransformer.close();
  }

  @experimental
  Future<AndroidKeyboardVisibilityState> getRootVisibilityState() async {
    final response = await _hostApi.getRootVisibilityState();
    return AndroidKeyboardVisibilityState.fromResponse(
      response,
      isMaybe: false,
    );
  }

  @override
  KeyboardVisibilityStatus get value => _resultTransformer.value;

  @override
  ValueStream<KeyboardVisibilityStatus> get stream => _resultTransformer.stream;
}

class _KeyboardVisibilityStatusTransformer {
  _KeyboardVisibilityStatusTransformer(
    _AndroidKeyboardFlutterApiHandler flutterApi,
  ) : _flutterApi = flutterApi {
    _initListeners();
  }

  KeyboardVisibilityStatus get value {
    if (_resultStreamCtl.hasValue) {
      return _resultStreamCtl.value;
    }
    throw StateError('No keyboard state has been emitted yet.');
  }

  ValueStream<KeyboardVisibilityStatus> get stream =>
      _resultStreamCtl.stream.distinct().shareValue();

  /// The Flutter API for receiving events from the native Android code.
  final _AndroidKeyboardFlutterApiHandler _flutterApi;

  Logger get _logger => UniteKeyboardVisibilityPlatform.logger;

  final _resultStreamCtl = BehaviorSubject<KeyboardVisibilityStatus>(
    sync: true,
  );

  late final StreamSubscription _selfSubscription;

  void _initListeners() {
    _flutterApi.visibilityStream.listen(_onVisibilityChanged);
    _flutterApi.animationStream.listen(_onAnimationChanged);
    _selfSubscription = stream.listen(
      (event) => _logger.d('Visibility verdict: ${event.name}'),
    );
  }

  void _onVisibilityChanged(AndroidKeyboardVisibilityState visibilityState) {
    _resultStreamCtl.add(visibilityState.status);
  }

  void _onAnimationChanged(AndroidKeyboardAnimationState animationState) {
    if (animationState is AndroidKeyboardAnimationStateEnd) {
      _resultStreamCtl.add(
        _flutterApi.animationSession!.sessionVerdict.graduate(),
      );
    }
  }

  Future<void> close() async {
    await Future.wait([
      _flutterApi.close(),
      _selfSubscription.cancel(),
      _resultStreamCtl.close(),
    ]);
  }
}

/// Internal implementation of [AndroidKeyboardVisibilityFlutterApi] to handle
/// platform callbacks.
class _AndroidKeyboardFlutterApiHandler
    implements AndroidKeyboardVisibilityFlutterApi {
  _AndroidKeyboardFlutterApiHandler() {
    AndroidKeyboardVisibilityFlutterApi.setUp(this);
  }
  _AndroidKeyboardAnimationSession? animationSession;

  Stream<AndroidKeyboardVisibilityState> get visibilityStream =>
      _visibilityStreamCtl.stream;

  Stream<AndroidKeyboardAnimationState> get animationStream =>
      _animationStreamCtl.stream;

  final _visibilityStreamCtl =
      StreamController<AndroidKeyboardVisibilityState>.broadcast(sync: true);

  final _animationStreamCtl =
      StreamController<AndroidKeyboardAnimationState>.broadcast(sync: true);

  Logger get _logger => UniteKeyboardVisibilityPlatform.logger;

  Future<void> close() async {
    AndroidKeyboardVisibilityFlutterApi.setUp(null);
    await Future.wait([
      _visibilityStreamCtl.close(),
      _animationStreamCtl.close(),
    ]);
  }

  void _handleNextAnimationState(AndroidKeyboardAnimationState nextState) {
    try {
      animationSession!.registerAnimationState(nextState);
      _animationStreamCtl.add(nextState);
    } catch (e) {
      _animationStreamCtl.addError(e);
      rethrow;
    }
  }

  @override
  void onVisibilityChanged(AndroidKeyboardVisibilityStateResponse response) {
    final nextVisibilityState = AndroidKeyboardVisibilityState.fromResponse(
      response,
      isMaybe: animationSession != null && !animationSession!.sessionFinished,
    );
    _logger.d(
      'onVisibilityChanged '
      '(${nextVisibilityState.status.name}, '
      '${nextVisibilityState.bottomInsetDevicePixels} device pixels)',
    );

    animationSession?.registerVisibilityState(nextVisibilityState);
    _visibilityStreamCtl.add(nextVisibilityState);
  }

  @override
  void onPrepare() {
    final nextAnimationState = AndroidKeyboardAnimationState.onPrepare();
    _logger.d('onPrepare');

    if (animationSession == null || animationSession!.sessionFinished) {
      // Start a new animation session.
      animationSession = _AndroidKeyboardAnimationSession();
    }

    _handleNextAnimationState(nextAnimationState);
  }

  @override
  void onStart(int lowerBoundDevicePixels, int upperBoundDevicePixels) {
    final nextAnimationState = AndroidKeyboardAnimationState.onStart(
      lowerBoundDevicePixels: lowerBoundDevicePixels,
      upperBoundDevicePixels: upperBoundDevicePixels,
    );
    _logger.d(
      'onStart '
      '($lowerBoundDevicePixels - $upperBoundDevicePixels device pixels)',
    );

    _handleNextAnimationState(nextAnimationState);
  }

  @override
  void onProgress(AndroidKeyboardVisibilityStateResponse response) {
    final nextAnimationState = AndroidKeyboardAnimationStateProgress(
      visibilityState: AndroidKeyboardVisibilityState.fromResponse(
        response,
        isMaybe: true,
      ),
    );
    _logger.d(
      'onProgress '
      '(${nextAnimationState.visibilityState.status.name}, '
      '${nextAnimationState.visibilityState.bottomInsetDevicePixels} '
      'device pixels)',
    );

    _handleNextAnimationState(nextAnimationState);
  }

  @override
  void onEnd() async {
    final nextAnimationState = AndroidKeyboardAnimationState.onEnd();
    _logger.d('onEnd');

    _handleNextAnimationState(nextAnimationState);
  }
}

class _AndroidKeyboardAnimationSession {
  _AndroidKeyboardAnimationSession();

  AndroidKeyboardVisibilityState? _previousVisibilityState;
  AndroidKeyboardAnimationState? _previousAnimationState;

  late final int lowerBoundDevicePixels;
  late final int upperBoundDevicePixels;

  AndroidKeyboardAnimationStateProgress? _lastRecordedProgressState;

  KeyboardVisibilityStatus get sessionVerdict {
    try {
      return _lastRecordedProgressState?.visibilityState.status.graduate() ??
          _previousVisibilityState!.status.graduate();
    } catch (e) {
      throw StateError('Unable to determine current session verdict: $e');
    }
  }

  // A session is considered finished if the previous recorded animation state
  // is an end state, indicating that the keyboard animation has completed.
  bool get sessionFinished {
    return _previousAnimationState is AndroidKeyboardAnimationStateEnd;
  }

  bool _checkNextAnimationStateValidity(
    AndroidKeyboardAnimationState nextState,
  ) {
    if (nextState == _previousAnimationState) {
      /**
       * Only duplicates of progress states are considered valid. This is
       * because the progress state can be emitted multiple times during an
       * ongoing animation.
       */

      return nextState is AndroidKeyboardAnimationStateProgress;
    }

    if (nextState is AndroidKeyboardAnimationStatePrepare) {
      /**
       * If the next state is a prepare state, it is considered invalid if
       * there is a previous animation state recorded. This is because the
       * animation prepare state should only be recorded at the start of a new
       * session.
       */

      return _previousAnimationState == null;
    }

    /**
     * If you reach here, the next state is not a prepare state. Start from here
     * at least one previous animation state and one previous visibility state
     * must have been recorded.
     *
     * Below is the check for that.
     */

    if (_previousVisibilityState == null || _previousAnimationState == null) {
      return false;
    }

    switch (nextState) {
      case AndroidKeyboardAnimationStateStart():
        if (_previousAnimationState is! AndroidKeyboardAnimationStatePrepare) {
          /**
           * AndroidKeyboardAnimationStateStart should come after
           * AndroidKeyboardAnimationStatePrepare.
           */

          return false;
        }

      case AndroidKeyboardAnimationStateProgress():
        if (_previousAnimationState is! AndroidKeyboardAnimationStateStart &&
            _previousAnimationState is! AndroidKeyboardAnimationStateProgress) {
          /**
           * AndroidKeyboardAnimationStateProgress should come after
           * AndroidKeyboardAnimationStateStart or
           * AndroidKeyboardAnimationStateProgress.
           */

          return false;
        }

      case AndroidKeyboardAnimationStateEnd():
        if (_previousAnimationState is! AndroidKeyboardAnimationStateStart &&
            _previousAnimationState is! AndroidKeyboardAnimationStateProgress) {
          /**
           * AndroidKeyboardAnimationStateEnd should come after
           * AndroidKeyboardAnimationStateStart or
           * AndroidKeyboardAnimationStateProgress.
           */

          return false;
        }
    }

    // Animation state validity checks passed.
    return true;
  }

  // ignore: use_setters_to_change_properties
  void registerVisibilityState(AndroidKeyboardVisibilityState state) {
    _previousVisibilityState = state;
  }

  void registerAnimationState(AndroidKeyboardAnimationState state) {
    if (!_checkNextAnimationStateValidity(state)) {
      throw AndroidKeyboardAnimationStateContractViolation(
        previousVisibilityState: _previousVisibilityState,
        previousAnimationState: _previousAnimationState,
        nextAnimationState: state,
      );
    }

    if (state is AndroidKeyboardAnimationStateStart) {
      lowerBoundDevicePixels = state.lowerBoundDevicePixels;
      upperBoundDevicePixels = state.upperBoundDevicePixels;
    }

    if (state is AndroidKeyboardAnimationStateProgress) {
      _lastRecordedProgressState = state;
    }

    _previousAnimationState = state;
  }
}
