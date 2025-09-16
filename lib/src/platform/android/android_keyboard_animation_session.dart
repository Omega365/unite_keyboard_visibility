import 'package:unite_keyboard_visibility/src/domain/android_keyboard_state.dart';
import 'package:unite_keyboard_visibility/src/domain/exceptions.dart';
import 'package:unite_keyboard_visibility/src/domain/keyboard_visibility_status.dart';

/// Represents the session for keyboard animation states on Android.
///
/// A single instance of this class is created for each keyboard animation
/// session. It tracks the visibility state and animation state throughout the
/// session and ensures that the animation states are valid according to the
/// Android keyboard animation contract.
class AndroidKeyboardAnimationSession {
  AndroidKeyboardAnimationSession();

  /// The lower bound of the keyboard animation in device pixels. This is set
  /// when the animation starts.
  late final int lowerBoundDevicePixels;

  /// The upper bound of the keyboard animation in device pixels. This is set
  /// when the animation starts.
  late final int upperBoundDevicePixels;

  /// Returns the session verdict based on the current session state.
  KeyboardVisibilityStatus getSessionVerdict() {
    try {
      return _lastRecordedProgressState?.visibilityState
              .toKeyboardVisibilityStatus(isDuringAnimation: false) ??
          _previousVisibilityState!
              .toKeyboardVisibilityStatus(isDuringAnimation: false);
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
