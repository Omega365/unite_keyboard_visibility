import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:unite_keyboard_visibility/unite_keyboard_visibility.dart';

// Example app logger.
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

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StreamSubscription _visibilitySub;
  KeyboardVisibilityStatus? _visibilityStatus;

  @override
  void initState() {
    super.initState();

    // Listen to keyboard visibility change events
    _visibilitySub = UniteKeyboardVisibility.instance.valueStream.listen((
      visible,
    ) {
      setState(() {
        _visibilityStatus = visible;
      });
      logger.i('Keyboard visibility changed: $visible');
    });
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
        appBar: AppBar(title: const Text('Unite Keyboard Visibility Example')),
        body: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              '${_visibilityStatus?.name}',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Press here',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
              },
              child: Text('Unfocus'),
            ),
          ],
        ),
      ),
    );
  }
}
