import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unite_keyboard_visibility/unite_keyboard_visibility.dart';
import 'package:unite_keyboard_visibility_example/examples/helpers.dart';
import 'package:unite_keyboard_visibility_example/main.dart';

class SimpleExample extends StatefulWidget {
  const SimpleExample({super.key});

  @override
  State<SimpleExample> createState() => _SimpleExampleState();
}

class _SimpleExampleState extends State<SimpleExample> {
  /// A subscription to log keyboard visibility changes.
  late final StreamSubscription _visibilitySub;

  @override
  void initState() {
    super.initState();

    // Listen to keyboard visibility change events
    _visibilitySub = UniteKeyboardVisibility.instance.valueStream.listen(
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
        appBar: AppBar(title: const Text('Unite Keyboard Visibility Example')),
        body: Column(
          children: [
            const SizedBox(height: 16),
            const CurrentVisibilityText(),
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
