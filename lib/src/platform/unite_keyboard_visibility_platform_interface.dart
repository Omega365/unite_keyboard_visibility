import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unite_keyboard_visibility/src/states/keyboard_state.dart';

abstract class UniteKeyboardVisibilityPlatform extends PlatformInterface {
  /// Constructs a UniteKeyboardVisibilityPlatform.
  UniteKeyboardVisibilityPlatform() : super(token: _token);

  static final Object _token = Object();

  static late UniteKeyboardVisibilityPlatform _instance;

  /// The default instance of [UniteKeyboardVisibilityPlatform] to use.
  static UniteKeyboardVisibilityPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UniteKeyboardVisibilityPlatform]
  /// when they register themselves.
  static set instance(UniteKeyboardVisibilityPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // Below are the methods that must be implemented by platform-specific
  // implementations of this interface.

  Future<void> initialize({
    required bool enableLogging,
    required bool forceFallback,
  });
  Future<void> dispose();

  KeyboardVisibilityStatus get value;
  ValueStream<KeyboardVisibilityStatus> get stream;
}
