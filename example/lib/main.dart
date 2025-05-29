import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unite_keyboard_visibility/unite_keyboard_visibility.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _uniteKeyboardVisibilityPlugin = UniteKeyboardVisibility();
  late final StreamSubscription _visibilitySub;

  @override
  void initState() {
    super.initState();

    // Listen to keyboard visibility change events
    _visibilitySub = _uniteKeyboardVisibilityPlugin.valueStream.listen((
      visible,
    ) {
      debugPrint('[D] TIME Keyboard state: $visible');
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
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final status = _uniteKeyboardVisibilityPlugin.value;
                debugPrint('Keyboard visibility status: $status');
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
