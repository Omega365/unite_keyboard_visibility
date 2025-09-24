import 'dart:async';

import 'package:logger/logger.dart';
import 'package:unite_keyboard_visibility/src/platform/android/android_keyboard_api_handlers.dart';

/// Lightweight helper that subscribes to Android keyboard API event streams and
/// forwards the received events to the provided [Logger].
///
/// This class is intended for debugging and diagnostic purposes. It listens to
/// the `visibilityStream` and `animationStream` exposed by
/// [AndroidKeyboardVisibilityFlutterApiService] and calls `logger.d` for each
/// incoming event. The class does not transform events or perform any
/// application logic; it only manages subscriptions and provides a convenient
/// lifecycle for starting and stopping logging.
class AndroidKeyboardApiEventLogger {
  /// Creates a logger that writes Flutter-side Android keyboard events to
  /// [logger].
  ///
  /// The [flutterApiService] supplies the event streams to subscribe to.
  AndroidKeyboardApiEventLogger({
    required Logger logger,
    required AndroidKeyboardVisibilityFlutterApiService flutterApiService,
  })  : _logger = logger,
        _flutterApiService = flutterApiService;

  /// The logger used to emit debug messages.
  final Logger _logger;

  /// The service that exposes the Android-side event streams.
  final AndroidKeyboardVisibilityFlutterApiService _flutterApiService;

  StreamSubscription? _visibilitySubscription;
  StreamSubscription? _animationSubscription;

  /// Starts listening to the `visibilityStream` and `animationStream` and logs
  /// each incoming event using `logger.d`.
  ///
  /// Call this during plugin initialization when you want to capture low-level
  /// Android keyboard events for debugging.
  void initialize() {
    _visibilitySubscription =
        _flutterApiService.visibilityStream.listen(_logger.d);

    _animationSubscription =
        _flutterApiService.animationStream.listen(_logger.d);
  }

  /// Cancels any active subscriptions and waits for cancellation to complete.
  ///
  /// This should be called during plugin disposal to avoid leaked subscriptions
  /// or retained resources.
  Future<void> dispose() async {
    await Future.wait([
      Future.sync(() => _visibilitySubscription?.cancel()),
      Future.sync(() => _animationSubscription?.cancel()),
    ]);
  }
}
