import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:unite_keyboard_visibility/unite_keyboard_visibility.dart';
import 'package:unite_keyboard_visibility_example/examples/full_example.dart';

final logger = Logger(
  printer: PrettyPrinter(methodCount: 1, printEmojis: false),
);

void main() async {
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.e('Unhandled platform error', error: error, stackTrace: stack);
    return true;
  };

  WidgetsFlutterBinding.ensureInitialized();
  await UniteKeyboardVisibility.instance.initialize(enableLogging: true);

  // runApp(const SimpleExample());
  runApp(const FullExample());
}
