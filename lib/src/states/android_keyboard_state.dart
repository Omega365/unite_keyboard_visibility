import 'package:dart_mappable/dart_mappable.dart';
import 'package:unite_keyboard_visibility/src/generated/messages.g.dart';
import 'package:unite_keyboard_visibility/src/states/keyboard_state.dart';

part 'android_keyboard_state.mapper.dart';

/// Represents the android keyboard state.
@MappableClass()
class AndroidKeyboardVisibilityState extends KeyboardVisibilityState
    with AndroidKeyboardVisibilityStateMappable {
  const AndroidKeyboardVisibilityState({
    required super.status,
    required this.bottomInsetDevicePixels,
  });

  factory AndroidKeyboardVisibilityState.fromResponse(
    AndroidKeyboardVisibilityStateResponse response, {
    required bool isMaybe,
  }) {
    final status = response.isVisible
        ? (isMaybe
              ? KeyboardVisibilityStatus.maybeOpen
              : KeyboardVisibilityStatus.open)
        : (isMaybe
              ? KeyboardVisibilityStatus.maybeClose
              : KeyboardVisibilityStatus.close);

    return AndroidKeyboardVisibilityState(
      status: status,
      bottomInsetDevicePixels: response.bottomInsetDevicePixels,
    );
  }

  /// The bottom inset of the keyboard in device pixels.
  final int bottomInsetDevicePixels;
}

/// Represents the android keyboard animation state.
@MappableClass()
abstract class AndroidKeyboardAnimationState
    with AndroidKeyboardAnimationStateMappable {
  const AndroidKeyboardAnimationState({required this.currentVerdict});

  const factory AndroidKeyboardAnimationState.onPrepare() =
      AndroidKeyboardAnimationStatePrepare;

  const factory AndroidKeyboardAnimationState.onStart({
    required int lowerBoundDevicePixels,
    required int upperBoundDevicePixels,
    required KeyboardVisibilityStatus currentVerdict,
  }) = AndroidKeyboardAnimationStateStart;

  const factory AndroidKeyboardAnimationState.onProgress({
    required AndroidKeyboardVisibilityState visibilityState,
    required KeyboardVisibilityStatus currentVerdict,
  }) = AndroidKeyboardAnimationStateProgress;

  const factory AndroidKeyboardAnimationState.onEnd({
    required KeyboardVisibilityStatus currentVerdict,
  }) = AndroidKeyboardAnimationStateEnd;

  /// The keyboard visibility status at the time of the animation state.
  final KeyboardVisibilityStatus? currentVerdict;
}

/// Represents the keyboard animation state when it is preparing to start.
@MappableClass()
class AndroidKeyboardAnimationStatePrepare extends AndroidKeyboardAnimationState
    with AndroidKeyboardAnimationStatePrepareMappable {
  const AndroidKeyboardAnimationStatePrepare() : super(currentVerdict: null);
}

/// Represents the keyboard animation state when it starts.
@MappableClass()
class AndroidKeyboardAnimationStateStart extends AndroidKeyboardAnimationState
    with AndroidKeyboardAnimationStateStartMappable {
  const AndroidKeyboardAnimationStateStart({
    required this.lowerBoundDevicePixels,
    required this.upperBoundDevicePixels,
    required super.currentVerdict,
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
  const AndroidKeyboardAnimationStateProgress({
    required this.visibilityState,
    required super.currentVerdict,
  });

  /// The state of the keyboard animation.
  final AndroidKeyboardVisibilityState visibilityState;
}

/// Represents the keyboard animation state when it ends.
@MappableClass()
class AndroidKeyboardAnimationStateEnd extends AndroidKeyboardAnimationState
    with AndroidKeyboardAnimationStateEndMappable {
  const AndroidKeyboardAnimationStateEnd({required super.currentVerdict});
}
