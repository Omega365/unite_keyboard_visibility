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
    /// The logger instance for logging events.
    final logger = UniteKeyboardVisibilityPlatform.logger;

    // Start listening to the keyboard visibility verdicts.
    _verdictStreamSubscription =
        _flutterApi.visibilityVerdictStream.distinct().listen((event) {
      logger.d('Final verdict: ${event.name}');
      _resultStreamCtl.add(event);
    });

    // The current state will be removed after every Hot-Restart so we need to
    // query it again to ensure we always have a valid initial value.
    Future.microtask(() async {
      late final AndroidKeyboardVisibilityState currentState;
      if (!_resultStreamCtl.hasValue) {
        currentState = await _queryCurrentState();
      }
      // Check again due to async gap.
      if (!_resultStreamCtl.hasValue) {
        logger.d('Hot-Restart detected, adding initial state');
        _resultStreamCtl.add(currentState.status);
      }
    });
  }

  /// The Flutter API for receiving events from the native Android code.
  final _flutterApi = _AndroidKeyboardFlutterApiHandler();

  // The host API for communicating with the native Android code.
  final _hostApi = AndroidKeyboardVisibilityHostApi();

  /// The stream subscription for listening to keyboard visibility verdicts.
  late final StreamSubscription _verdictStreamSubscription;

  /// The stream controller for the emiting the final keyboard visibility
  /// status.
  final _resultStreamCtl = BehaviorSubject<KeyboardVisibilityStatus>(
    sync: true,
  );

  /// Registers this class as the default instance of
  /// [UniteKeyboardVisibilityPlatform].
  static void registerWith() {
    UniteKeyboardVisibilityPlatform.instance = UniteKeyboardVisibilityAndroid();
  }

  /// Queries the current keyboard visibility state from the native Android
  /// code.
  Future<AndroidKeyboardVisibilityState> _queryCurrentState() async {
    final response = await _hostApi.getVisibilityStateFromRootView();
    return AndroidKeyboardVisibilityState.fromResponse(
      response,
      isMaybe: _flutterApi.isInAnimationSession,
    );
  }

  @override
  Future<void> close() async {
    await Future.wait([
      _flutterApi.close(),
      _verdictStreamSubscription.cancel(),
      _resultStreamCtl.close(),
    ]);
  }

  @override
  KeyboardVisibilityStatus get value {
    if (_resultStreamCtl.hasValue) {
      return _resultStreamCtl.value;
    }
    throw StateError('No keyboard state has been emitted yet.');
  }

  @override
  ValueStream<KeyboardVisibilityStatus> get stream => _resultStreamCtl.stream;
}

/// Internal implementation of [AndroidKeyboardVisibilityFlutterApi] to handle
/// platform callbacks.
///
/// Converts raw platform events into useful information and deduces the current
/// keyboard visibility status.
class _AndroidKeyboardFlutterApiHandler
    implements AndroidKeyboardVisibilityFlutterApi {
  _AndroidKeyboardFlutterApiHandler() {
    AndroidKeyboardVisibilityFlutterApi.setUp(this);
  }

  /// Returns a stream of keyboard visibility verdicts combined from both
  /// [visibilityStream] and [animationStream].
  Stream<KeyboardVisibilityStatus> get visibilityVerdictStream {
    return Rx.merge<KeyboardVisibilityStatus>([
      visibilityStream.map((e) => e.status),
      animationStream.whereType<AndroidKeyboardAnimationStateEnd>().map(
            (e) => e.currentVerdict!,
          ),
    ]);
  }

  /// The stream of keyboard visibility state changes.
  Stream<AndroidKeyboardVisibilityState> get visibilityStream =>
      _visibilityStreamCtl.stream;

  /// The stream of keyboard animation state changes.
  Stream<AndroidKeyboardAnimationState> get animationStream =>
      _animationStreamCtl.stream;

  // Whether there is an ongoing animation session.
  bool get isInAnimationSession => _animationSession != null;

  /// The stream controller for keyboard visibility state changes.
  final _visibilityStreamCtl =
      StreamController<AndroidKeyboardVisibilityState>.broadcast(sync: true);

  /// The stream controller for keyboard animation state changes.
  final _animationStreamCtl =
      StreamController<AndroidKeyboardAnimationState>.broadcast(sync: true);

  /// The logger instance for logging API events.
  Logger get _logger => UniteKeyboardVisibilityPlatform.logger;

  // The current active animation session.
  _AndroidKeyboardAnimationSession? _animationSession;

  /// Closes the API and cleans up resources.
  Future<void> close() async {
    AndroidKeyboardVisibilityFlutterApi.setUp(null);
    await Future.wait([
      _visibilityStreamCtl.close(),
      _animationStreamCtl.close(),
    ]);
  }

  /// Helper method to check if the next animation state is valid and add it to
  /// the animation stream.
  void _handleNextAnimationState(AndroidKeyboardAnimationState nextState) {
    try {
      _animationSession!.registerAnimationState(nextState);
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
      isMaybe: isInAnimationSession,
    );
    _logger.d(
      'onVisibilityChanged '
      '(${nextVisibilityState.status.name}, '
      '${nextVisibilityState.bottomInsetDevicePixels} device pixels)',
    );

    _animationSession?.registerVisibilityState(nextVisibilityState);
    _visibilityStreamCtl.add(nextVisibilityState);
  }

  @override
  void onPrepare() {
    final nextAnimationState = AndroidKeyboardAnimationState.onPrepare();
    _logger.d('onPrepare');

    // Start a new animation session.
    _animationSession = _AndroidKeyboardAnimationSession();

    _handleNextAnimationState(nextAnimationState);
  }

  @override
  void onStart(int lowerBoundDevicePixels, int upperBoundDevicePixels) {
    final nextAnimationState = AndroidKeyboardAnimationState.onStart(
      lowerBoundDevicePixels: lowerBoundDevicePixels,
      upperBoundDevicePixels: upperBoundDevicePixels,
      currentVerdict: _animationSession!.getSessionVerdict(),
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
      currentVerdict: _animationSession!.getSessionVerdict(),
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
  void onEnd() {
    final nextAnimationState = AndroidKeyboardAnimationState.onEnd(
      currentVerdict: _animationSession!.getSessionVerdict(),
    );
    _logger.d('onEnd');

    _handleNextAnimationState(nextAnimationState);
    _animationSession = null;
  }
}

/// Represents the session for keyboard animation states on Android.
///
/// A single instance of this class is created for each keyboard animation
/// session. It tracks the visibility state and animation state throughout the
/// session and ensures that the animation states are valid according to the
/// Android keyboard animation contract.
class _AndroidKeyboardAnimationSession {
  _AndroidKeyboardAnimationSession();

  /// The lower bound of the keyboard animation in device pixels. This is set
  /// when the animation starts.
  late final int lowerBoundDevicePixels;

  /// The upper bound of the keyboard animation in device pixels. This is set
  /// when the animation starts.
  late final int upperBoundDevicePixels;

  /// Returns the session verdict based on the current session state.
  KeyboardVisibilityStatus getSessionVerdict() {
    try {
      return _lastRecordedProgressState?.visibilityState.status.graduate() ??
          _previousVisibilityState!.status.graduate();
    } catch (e) {
      throw StateError('Unable to determine current session verdict: $e');
    }
  }

  AndroidKeyboardVisibilityState? _previousVisibilityState;
  AndroidKeyboardAnimationState? _previousAnimationState;
  AndroidKeyboardAnimationStateProgress? _lastRecordedProgressState;

  /// Checks if the next animation state satisfies the Android keyboard
  /// animation contract.
  ///
  /// If this returns `false`, something is wrong with the sequence of animation
  /// states, and an [AndroidKeyboardAnimationStateContractViolation] will be
  /// thrown when calling [registerAnimationState].
  bool _checkNextAnimationStateValidity(
    AndroidKeyboardAnimationState nextState,
  ) {
    if (_previousAnimationState is AndroidKeyboardAnimationStateEnd) {
      /**
       * If the previous animation state is an end state, no further animation
       * states are allowed.
       */

      return false;
    }

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
       * If the next state is a prepare state, it is considered invalid if there
       * is a previous animation state recorded. This is because the animation
       * prepare state should only be recorded at the start of a new session.
       */

      return _previousAnimationState == null;
    }

    /**
     * If you reach here, the next state is not a prepare state. Starting from
     * here at least one previous animation state and one previous visibility
     * state must have been recorded.
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

  /// Registers the next visibility state for the current animation session.
  // ignore: use_setters_to_change_properties
  void registerVisibilityState(AndroidKeyboardVisibilityState state) {
    _previousVisibilityState = state;
  }

  /// Registers the next animation state for the current animation session.
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
