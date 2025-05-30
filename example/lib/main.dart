import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:unite_keyboard_visibility/unite_keyboard_visibility.dart';

// Toggle between using the plugin logger or the example app logger.
const _usePluginLogger = false;

// Example app logger.
final logger = Logger(
  printer: PrettyPrinter(methodCount: 1, printEmojis: false),
  level: _usePluginLogger ? Level.warning : Level.all,
);

void main() async {
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.e('Unhandled platform error', error: error, stackTrace: stack);
    return true;
  };

  WidgetsFlutterBinding.ensureInitialized();
  await UniteKeyboardVisibility.instance.initialize(
    enableLogging: _usePluginLogger,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _uniteKeyboardVisibilityPlugin = UniteKeyboardVisibility.instance;
  late final StreamSubscription _visibilitySub;

  @override
  void initState() {
    super.initState();

    // Listen to keyboard visibility change events
    _visibilitySub = _uniteKeyboardVisibilityPlugin.valueStream.listen(
      (visible) => logger.i('Keyboard visibility changed: $visible'),
    );
  }

  @override
  void dispose() {
    _visibilitySub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final status = _uniteKeyboardVisibilityPlugin.value;
                logger.i('Current keyboard visibility: $status');
              },
              child: const Text('Check Keyboard Visibility'),
            ),
            const SizedBox(height: 16),
            TextField(),
          ],
        ),
      ),
    );
  }
}
