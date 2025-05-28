import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'unite_keyboard_visibility_method_channel.dart';

abstract class UniteKeyboardVisibilityPlatform extends PlatformInterface {
  /// Constructs a UniteKeyboardVisibilityPlatform.
  UniteKeyboardVisibilityPlatform() : super(token: _token);

  static final Object _token = Object();

  static UniteKeyboardVisibilityPlatform _instance = MethodChannelUniteKeyboardVisibility();

  /// The default instance of [UniteKeyboardVisibilityPlatform] to use.
  ///
  /// Defaults to [MethodChannelUniteKeyboardVisibility].
  static UniteKeyboardVisibilityPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UniteKeyboardVisibilityPlatform] when
  /// they register themselves.
  static set instance(UniteKeyboardVisibilityPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
