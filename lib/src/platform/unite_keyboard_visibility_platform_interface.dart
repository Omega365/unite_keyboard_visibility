import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unite_keyboard_visibility/src/platform/android/unite_keyboard_visibility_android.dart';
import 'package:unite_keyboard_visibility/src/platform/fallback/unite_keyboard_visibility_fallback.dart';
import 'package:unite_keyboard_visibility/src/states/keyboard_state.dart';

final _notInitializedError = StateError(
  'UniteKeyboardVisibility.initialize() has not been called.',
);

abstract class UniteKeyboardVisibilityPlatform extends PlatformInterface {
  /// Constructs a UniteKeyboardVisibilityPlatform.
  UniteKeyboardVisibilityPlatform() : super(token: _token);

  /// Returns the correct platform-specific implementation based on the current
  /// platform.
  factory UniteKeyboardVisibilityPlatform._internal({
    required bool forceFallback,
  }) {
    if (kIsWeb) {
      throw UnsupportedError(
        'UniteKeyboardVisibility is not supported on web.',
      );
    }

    if (forceFallback || Platform.isIOS) {
      return UniteKeyboardVisibilityFallback();
    }

    if (Platform.isAndroid) {
      return UniteKeyboardVisibilityAndroid();
    }

    throw UnsupportedError(
      'UniteKeyboardVisibility is not supported on this platform: '
      '${Platform.operatingSystem}.',
    );
  }

  static final Object _token = Object();
  static UniteKeyboardVisibilityPlatform? _instance;

  /// The default instance of [UniteKeyboardVisibilityPlatform] to use.
  static UniteKeyboardVisibilityPlatform get instance {
    if (_instance == null) {
      throw _notInitializedError;
    }
    return _instance!;
  }

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UniteKeyboardVisibilityPlatform]
  /// when they register themselves.
  static set instance(UniteKeyboardVisibilityPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  static void initialize({
    required bool enableLogging,
    required bool forceFallback,
  }) {
    // Reinitialize logger.
    _logger?.close();
    _logger = Logger(
      printer: SimplePrinter(colors: false, printTime: true),
      level: enableLogging ? Level.all : Level.off,
    );

    // Replace the current instance with a new one.
    _instance?.close();
    instance = UniteKeyboardVisibilityPlatform._internal(
      forceFallback: forceFallback,
    );
  }

  static Logger? _logger;

  /// The logger for the platform implementation.
  static Logger get logger {
    if (_logger == null) {
      throw _notInitializedError;
    }
    return _logger!;
  }

  /// Closes the platform instance and releases resources.
  void close() {
    // This method can be overridden by platform-specific implementations.
  }

  /// {@template UniteKeyboardVisibilityPlatform.value}
  /// Returns the current keyboard visibility.
  /// {@endtemplate}
  KeyboardVisibilityStatus get value;

  /// {@template UniteKeyboardVisibilityPlatform.stream}
  /// Watch a stream of keyboard visibility. The current value will be emitted
  /// immediately for any new listener.
  /// {@endtemplate}
  ValueStream<KeyboardVisibilityStatus> get stream;
}
