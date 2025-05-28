import 'package:meta/meta.dart';
import 'package:unite_keyboard_visibility/src/generated/messages.g.dart';

/// Represents the keyboard state.
///
/// Since pigeon does not support [toString], this is a wrapper around it to
/// provide a [toString] implementation.
class KeyboardVisibilityState extends KeyboardVisibilityStateResponse {
  KeyboardVisibilityState({
    required super.isVisible,
    required super.bottomInsetDevicePixels,
  });

  @internal
  KeyboardVisibilityState.fromResponse(KeyboardVisibilityStateResponse response)
    : super(
        isVisible: response.isVisible,
        bottomInsetDevicePixels: response.bottomInsetDevicePixels,
      );

  @override
  String toString() =>
      '$KeyboardVisibilityState('
      'isVisible: $isVisible, '
      'bottomInsetDevicePixels: $bottomInsetDevicePixels'
      ')';
}

/// Represents a keyboard animation state.
@immutable
sealed class KeyboardAnimationState {
  const KeyboardAnimationState();

  /// {@macro KeyboardAnimationStatePrepare()}
  const factory KeyboardAnimationState.onPrepare() =
      KeyboardAnimationStatePrepare;

  /// {@macro KeyboardAnimationStateStart()}
  const factory KeyboardAnimationState.onStart({
    required int lowerBoundDevicePixels,
    required int upperBoundDevicePixels,
  }) = KeyboardAnimationStateStart;

  /// {@macro KeyboardAnimationStateProgress()}
  const factory KeyboardAnimationState.onProgress({
    required KeyboardVisibilityState keyboardState,
  }) = KeyboardAnimationStateProgress;

  /// {@macro KeyboardAnimationStateEnd()}
  const factory KeyboardAnimationState.onEnd() = KeyboardAnimationStateEnd;

  @mustBeOverridden
  @override
  String toString();
}

/// Represents the keyboard animation state when it is preparing to start.
class KeyboardAnimationStatePrepare extends KeyboardAnimationState {
  /// {@template KeyboardAnimationStatePrepare()}
  /// Creates a [KeyboardAnimationStatePrepare].
  /// {@endtemplate}
  const KeyboardAnimationStatePrepare();

  @override
  String toString() => 'KeyboardAnimationStatePrepare()';
}

/// Represents the keyboard animation state when it starts.
class KeyboardAnimationStateStart extends KeyboardAnimationState {
  /// {@template KeyboardAnimationStateStart()}
  /// Creates a [KeyboardAnimationStateStart].
  ///
  /// [lowerBoundDevicePixels] and [upperBoundDevicePixels] are the bounds of
  /// the keyboard animation in device pixels.
  /// {@endtemplate}
  const KeyboardAnimationStateStart({
    required this.lowerBoundDevicePixels,
    required this.upperBoundDevicePixels,
  });

  /// The lower bound of the keyboard animation in device pixels.
  final int lowerBoundDevicePixels;

  /// The upper bound of the keyboard animation in device pixels.
  final int upperBoundDevicePixels;

  @override
  String toString() =>
      'KeyboardAnimationStateStart('
      'lowerBoundDevicePixels: $lowerBoundDevicePixels, '
      'upperBoundDevicePixels: $upperBoundDevicePixels'
      ')';
}

/// Represents the keyboard animation state when it is in progress.
class KeyboardAnimationStateProgress extends KeyboardAnimationState {
  /// {@template KeyboardAnimationStateProgress()}
  /// Creates a [KeyboardAnimationStateProgress].
  ///
  /// [keyboardState] is the current state of this keyboard animation.
  /// {@endtemplate}
  const KeyboardAnimationStateProgress({required this.keyboardState});

  /// The state of the keyboard animation in device pixels.
  final KeyboardVisibilityState keyboardState;

  @override
  String toString() =>
      'KeyboardAnimationStateProgress('
      'keyboardState: $keyboardState'
      ')';
}

/// Represents the keyboard animation state when it ends.
class KeyboardAnimationStateEnd extends KeyboardAnimationState {
  /// {@template KeyboardAnimationStateEnd()}
  /// Creates a [KeyboardAnimationStateEnd].
  /// {@endtemplate}
  const KeyboardAnimationStateEnd();

  @override
  String toString() => 'KeyboardAnimationStateEnd()';
}
