import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unite_keyboard_visibility/src/generated/messages.g.dart';
import 'package:unite_keyboard_visibility/src/platform/unite_keyboard_visibility_platform_interface.dart';
import 'package:unite_keyboard_visibility/src/states/android_keyboard_state.dart';

/// An implementation of [UniteKeyboardVisibilityPlatform] for Android.
@protected
class AndroidMethodChannelUniteKeyboardVisibility
    extends UniteKeyboardVisibilityPlatform {
  /// Unnamed constructor for [UniteKeyboardVisibilityPlatform] to use.
  @protected
  AndroidMethodChannelUniteKeyboardVisibility();

  // The host API for communicating with the native Android code.
  final _hostApi = AndroidKeyboardVisibilityHostApi();

  /// The Flutter API for receiving events from the native Android code.
  final _flutterApi = _AndroidKeyboardFlutterApiHandler();

  @experimental
  Future<AndroidKeyboardVisibilityState> getRootVisibilityState() async {
    final response = await _hostApi.getRootVisibilityState();
    return AndroidKeyboardVisibilityState.fromResponse(
      response,
      isMaybe: false,
    );
  }

  @override
  AndroidKeyboardVisibilityState get current {
    if (_flutterApi.visibilitySubj.hasValue) {
      return _flutterApi.visibilitySubj.value;
    }

    throw StateError('No keyboard state has been emitted by the platform yet.');
  }

  @override
  ValueStream<AndroidKeyboardVisibilityState> watch() =>
      _flutterApi.visibilitySubj.stream;
}

/// Internal implementation of [AndroidKeyboardVisibilityFlutterApi] to handle
/// platform callbacks.
class _AndroidKeyboardFlutterApiHandler
    implements AndroidKeyboardVisibilityFlutterApi {
  _AndroidKeyboardFlutterApiHandler() {
    AndroidKeyboardVisibilityFlutterApi.setUp(this);
  }

  final visibilitySubj = BehaviorSubject<AndroidKeyboardVisibilityState>();
  final animationSubj = BehaviorSubject<AndroidKeyboardAnimationState>();

  // _AndroidKeyboardActionSession? _actionSession;

  @override
  void onVisibilityChanged(AndroidKeyboardVisibilityStateResponse response) {
    visibilitySubj.add(
      AndroidKeyboardVisibilityState.fromResponse(response, isMaybe: true),
    );
  }

  @override
  void onPrepare() {
    animationSubj.add(AndroidKeyboardAnimationState.onPrepare());
  }

  @override
  void onStart(int lowerBoundDevicePixels, int upperBoundDevicePixels) {
    animationSubj.add(
      AndroidKeyboardAnimationState.onStart(
        lowerBoundDevicePixels: lowerBoundDevicePixels,
        upperBoundDevicePixels: upperBoundDevicePixels,
      ),
    );
  }

  @override
  void onProgress(AndroidKeyboardVisibilityStateResponse response) {
    animationSubj.add(
      AndroidKeyboardAnimationState.onProgress(
        visibilityState: AndroidKeyboardVisibilityState.fromResponse(
          response,
          isMaybe: true,
        ),
      ),
    );
  }

  @override
  void onEnd() {
    animationSubj.add(AndroidKeyboardAnimationState.onEnd());
  }
}

class _AndroidKeyboardActionSession {
  _AndroidKeyboardActionSession();

  AndroidKeyboardVisibilityState? _previousVisibilityState;
  AndroidKeyboardAnimationState? _previousAnimationState;

  // A session is considered finished if the previous recorded animation state
  // is an end state, indicating that the keyboard animation has completed.
  bool get sessionFinished {
    return _previousAnimationState is AndroidKeyboardAnimationStateEnd;
  }

  bool _checkNextVisibilityStateValidity(
    AndroidKeyboardVisibilityState nextState,
  ) {
    if (nextState == _previousVisibilityState) {
      /**
       * Duplicate states are always considered valid under any situation. If
       * you don't want them, use the `distinct` operator on the stream.
       */

      return true;
    }

    if (sessionFinished) {
      /**
       * If the session is finished, any new visibility state is considered
       * invalid since it should not change after the keyboard animation has
       * ended. You must start a new session to record new states.
       */

      return false;
    }

    if (_previousAnimationState == null) {
      /**
       * If a visibility state is recorded without any prior animation state, it
       * is considered invalid.
       *
       * This situation can occur when the app goes into or resumes from the
       * background without any prior animation state due to the following
       * issues:
       *
       *  - https://github.com/flutter/flutter/issues/107153
       *  - https://github.com/flutter/flutter/issues/52599
       */

      return false;
    }

    if (_previousAnimationState is AndroidKeyboardAnimationStateEnd) {
      /**
       * If the previous animation state is an end state, it is considered
       * invalid to record a new visibility state without starting a new
       * session.
       */

      return false;
    }

    // State validity checks passed.
    return true;
  }

  bool _checkNextAnimationStateValidity(
    AndroidKeyboardAnimationState nextState,
  ) {
    if (nextState == _previousAnimationState) {
      /**
       * Duplicate states are always considered valid under any situation. If
       * you don't want them, use the `distinct` operator on the stream.
       */

      return true;
    }

    if (nextState is AndroidKeyboardAnimationStatePrepare) {
      if (_previousVisibilityState != null || _previousAnimationState != null) {
        /**
           * If the next state is a prepare state, it is considered invalid if
           * there is a previous visibility state or animation state recorded.
           * This is because the animation prepare state should only be recorded
           * at the start of a new session, when everything is null.
           */

        return false;
      }
    }

    if (_previousVisibilityState == null || _previousAnimationState == null) {
      /**
       * If the next state is not AndroidKeyboardAnimationStatePrepare, both a
       * visibility state and a animation state must have been recorded before
       * the next animation comes.
       */

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
            _previousVisibilityState
                is! AndroidKeyboardAnimationStateProgress) {
          /**
           * AndroidKeyboardAnimationStateProgress should come after
           * AndroidKeyboardAnimationStateStart or
           * AndroidKeyboardAnimationStateProgress.
           */

          return false;
        }
    }

    // State validity checks passed.
    return true;
  }

  bool recordVisibilityState(AndroidKeyboardVisibilityState state) {
    if (!_checkNextVisibilityStateValidity(state)) {
      return false;
    }

    _previousVisibilityState = state;
    return true;
  }

  bool recordAnimationState(AndroidKeyboardAnimationState state) {
    if (!_checkNextAnimationStateValidity(state)) {
      return false;
    }

    _previousAnimationState = state;
    return true;
  }
}
