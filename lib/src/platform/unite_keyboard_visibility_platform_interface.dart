import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unite_keyboard_visibility/src/platform/unite_keyboard_visibility_android.dart';
import 'package:unite_keyboard_visibility/src/states/keyboard_state.dart';

abstract class UniteKeyboardVisibilityPlatform extends PlatformInterface {
  /// Constructs a UniteKeyboardVisibilityPlatform.
  UniteKeyboardVisibilityPlatform() : super(token: _token);

  /// Returns the correct platform-specific implementation based on the current
  /// platform.
  factory UniteKeyboardVisibilityPlatform._internal() {
    if (kIsWeb) {
      throw UnsupportedError(
        'UniteKeyboardVisibility is not supported on web.',
      );
    }

    if (Platform.isAndroid) {
      return AndroidMethodChannelUniteKeyboardVisibility();
    }

    throw UnsupportedError(
      'UniteKeyboardVisibility is not supported on '
      '${Platform.operatingSystem}.',
    );
  }

  static final Object _token = Object();

  static UniteKeyboardVisibilityPlatform _instance =
      UniteKeyboardVisibilityPlatform._internal();

  /// The default instance of [UniteKeyboardVisibilityPlatform] to use.
  static UniteKeyboardVisibilityPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UniteKeyboardVisibilityPlatform]
  /// when they register themselves.
  static set instance(UniteKeyboardVisibilityPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns the current keyboard visibility state.
  KeyboardVisibilityState get current;

  /// Watch a stream of keyboard states. The current state will be emitted
  /// immediately for any new listener.
  ValueStream<KeyboardVisibilityState> watch();
}
