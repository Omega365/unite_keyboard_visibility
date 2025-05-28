import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:unite_keyboard_visibility/src/keyboard_state.dart';
import 'package:unite_keyboard_visibility/src/platform/unite_keyboard_visibility_method_channel.dart';

abstract class UniteKeyboardVisibilityPlatform extends PlatformInterface {
  /// Constructs a UniteKeyboardVisibilityPlatform.
  UniteKeyboardVisibilityPlatform() : super(token: _token);

  static final Object _token = Object();

  static UniteKeyboardVisibilityPlatform _instance =
      MethodChannelUniteKeyboardVisibility();

  /// The default instance of [UniteKeyboardVisibilityPlatform] to use.
  ///
  /// Defaults to [MethodChannelUniteKeyboardVisibility].
  static UniteKeyboardVisibilityPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UniteKeyboardVisibilityPlatform]
  /// when they register themselves.
  static set instance(UniteKeyboardVisibilityPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  KeyboardVisibilityState getCurrentState() {
    throw UnimplementedError('getCurrentState() has not been implemented.');
  }

  Future<KeyboardVisibilityState> getPlatformState() {
    throw UnimplementedError('getPlatformState() has not been implemented.');
  }

  Stream<KeyboardVisibilityState> watchVisibilityStates() {
    throw UnimplementedError('watchStates() has not been implemented.');
  }

  Stream<KeyboardAnimationState> watchAnimationStates() {
    throw UnimplementedError(
      'watchAnimationStates() has not been implemented.',
    );
  }
}
