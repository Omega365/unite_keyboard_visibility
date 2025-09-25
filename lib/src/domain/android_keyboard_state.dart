import 'package:dart_mappable/dart_mappable.dart';
import 'package:unite_keyboard_visibility/src/domain/keyboard_visibility_status.dart';
import 'package:unite_keyboard_visibility/src/generated/messages.g.dart';

part 'android_keyboard_state.mapper.dart';

/// Represents the android keyboard state.
@MappableClass()
class AndroidKeyboardVisibilityState
    with AndroidKeyboardVisibilityStateMappable {
  const AndroidKeyboardVisibilityState({
    required this.isVisible,
    required this.bottomInsetDevicePixels,
  });

  factory AndroidKeyboardVisibilityState.fromPigeonResponse(
    AndroidKeyboardVisibilityStateResponse response,
  ) {
    return AndroidKeyboardVisibilityState(
      isVisible: response.isVisible,
      bottomInsetDevicePixels: response.bottomInsetDevicePixels,
    );
  }

  /// Whether the keyboard is visible or not.
  final bool isVisible;

  /// The bottom inset of the keyboard in device pixels.
  final int bottomInsetDevicePixels;

  KeyboardVisibilityStatus toKeyboardVisibilityStatus({
    required bool isDuringAnimation,
  }) {
    if (isVisible) {
      return isDuringAnimation
          ? KeyboardVisibilityStatus.maybeOpen
          : KeyboardVisibilityStatus.open;
    } else {
      return isDuringAnimation
          ? KeyboardVisibilityStatus.maybeClose
          : KeyboardVisibilityStatus.close;
    }
  }
}

/// Represents the android keyboard animation state.
@MappableClass()
abstract class AndroidKeyboardAnimationState
    with AndroidKeyboardAnimationStateMappable {
  const AndroidKeyboardAnimationState();

  const factory AndroidKeyboardAnimationState.onPrepare() =
      AndroidKeyboardAnimationStatePrepare;

  const factory AndroidKeyboardAnimationState.onStart({
    required int lowerBoundDevicePixels,
    required int upperBoundDevicePixels,
  }) = AndroidKeyboardAnimationStateStart;

  const factory AndroidKeyboardAnimationState.onProgress({
    required AndroidKeyboardVisibilityState visibilityState,
  }) = AndroidKeyboardAnimationStateProgress;

  const factory AndroidKeyboardAnimationState.onEnd() =
      AndroidKeyboardAnimationStateEnd;
}

/// Represents the keyboard animation state when it is preparing to start.
@MappableClass()
class AndroidKeyboardAnimationStatePrepare extends AndroidKeyboardAnimationState
    with AndroidKeyboardAnimationStatePrepareMappable {
  const AndroidKeyboardAnimationStatePrepare();
}

/// Represents the keyboard animation state when it starts.
@MappableClass()
class AndroidKeyboardAnimationStateStart extends AndroidKeyboardAnimationState
    with AndroidKeyboardAnimationStateStartMappable {
  const AndroidKeyboardAnimationStateStart({
    required this.lowerBoundDevicePixels,
    required this.upperBoundDevicePixels,
  });

  /// The lower bound of the keyboard animation in device pixels.
  final int lowerBoundDevicePixels;

  /// The upper bound of the keyboard animation in device pixels.
  final int upperBoundDevicePixels;
}

/// Represents the keyboard animation state when it is in progress.
@MappableClass()
class AndroidKeyboardAnimationStateProgress
    extends AndroidKeyboardAnimationState
    with AndroidKeyboardAnimationStateProgressMappable {
  const AndroidKeyboardAnimationStateProgress({required this.visibilityState});

  /// The state of the keyboard animation.
  final AndroidKeyboardVisibilityState visibilityState;
}

/// Represents the keyboard animation state when it ends.
@MappableClass()
class AndroidKeyboardAnimationStateEnd extends AndroidKeyboardAnimationState
    with AndroidKeyboardAnimationStateEndMappable {
  const AndroidKeyboardAnimationStateEnd();
}
