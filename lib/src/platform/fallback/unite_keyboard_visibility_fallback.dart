import 'dart:async';

import 'package:flutter_keyboard_visibility_temp_fork/flutter_keyboard_visibility_temp_fork.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unite_keyboard_visibility/src/platform/unite_keyboard_visibility_platform_interface.dart';
import 'package:unite_keyboard_visibility/unite_keyboard_visibility.dart';

class UniteKeyboardVisibilityFallback extends UniteKeyboardVisibilityPlatform {
  /// Registers this class as the default instance of
  /// [UniteKeyboardVisibilityPlatform].
  static void registerWith() {
    UniteKeyboardVisibilityPlatform.instance =
        UniteKeyboardVisibilityFallback();
  }

  /// The stream subscription for listening to keyboard visibility verdicts.
  late final StreamSubscription _verdictStreamSubscription;

  /// The stream controller for the emiting the final keyboard visibility
  /// status.
  final _resultStreamCtl = BehaviorSubject<KeyboardVisibilityStatus>(
    sync: true,
  );

  @override
  Future<void> initialize({
    required bool enableLogging,
    required bool forceFallback,
  }) async {
    final keyboardVisibilityController = KeyboardVisibilityController();

    // Start listening to the keyboard visibility verdicts.
    _verdictStreamSubscription = keyboardVisibilityController.onChange
        .startWith(keyboardVisibilityController.isVisible)
        .listen((isVisible) {
      _resultStreamCtl.add(
        isVisible
            ? KeyboardVisibilityStatus.open
            : KeyboardVisibilityStatus.close,
      );
    });
  }

  @override
  Future<void> dispose() async {
    await Future.wait([
      _verdictStreamSubscription.cancel(),
      _resultStreamCtl.close(),
    ]);
  }

  @override
  KeyboardVisibilityStatus get value {
    if (_resultStreamCtl.hasValue) {
      return _resultStreamCtl.value;
    }
    throw StateError('No keyboard state has been emitted yet.');
  }

  @override
  ValueStream<KeyboardVisibilityStatus> get stream => _resultStreamCtl.stream;
}
