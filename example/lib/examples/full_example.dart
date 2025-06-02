import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unite_keyboard_visibility/unite_keyboard_visibility.dart';
import 'package:unite_keyboard_visibility_example/examples/helpers.dart';
import 'package:unite_keyboard_visibility_example/main.dart';

class FullExample extends StatefulWidget {
  const FullExample({super.key});

  @override
  State<FullExample> createState() => _FullExampleState();
}

class _FullExampleState extends State<FullExample> {
  /// A subscription to log keyboard visibility changes.
  late final StreamSubscription _visibilitySub;

  /// The focus node for the text field in this example.
  final _focusNode = KeyboardVisibilityFocusNode();

  /// Whether to enable unfocusing behavior.
  bool _enableUnfocusing = true;

  /// The default unfocus mode for the [KeyboardVisibilityUnfocuser].
  KeyboardVisibilityUnfocusMode _defaultUnfocusMode =
      KeyboardVisibilityUnfocusMode.lazy;

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
    return KeyboardVisibilityUnfocuser(
      enableUnfocusing: _enableUnfocusing,
      defaultUnfocusMode: _defaultUnfocusMode,
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Unite Keyboard Visibility Example'),
          ),
          body: Column(
            children: [
              const SizedBox(height: 16),
              const CurrentVisibilityText(),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    labelText: 'Press here',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _ConfigurationButtons(
                currentEnableUnfocusing: _enableUnfocusing,
                currentDefaultUnfocusMode: _defaultUnfocusMode,
                currentFocusNodeUnfocusMode: _focusNode.unfocusMode,
                onUnfocusPressed: () {
                  _focusNode.unfocus();
                },
                onEnableUnfocusingPressed: () {
                  setState(() {
                    _enableUnfocusing = !_enableUnfocusing;
                  });
                },
                onDefaultUnfocusModePressed: () {
                  setState(() {
                    _defaultUnfocusMode =
                        _nextUnfocusMode(_defaultUnfocusMode) ??
                        KeyboardVisibilityUnfocusMode.off;
                  });
                },
                onFocusNodeUnfocusModePressed: () {
                  setState(() {
                    _focusNode.unfocusMode = _nextUnfocusMode(
                      _focusNode.unfocusMode,
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  KeyboardVisibilityUnfocusMode? _nextUnfocusMode(
    KeyboardVisibilityUnfocusMode? current,
  ) {
    switch (current) {
      case null:
        return KeyboardVisibilityUnfocusMode.off;
      case KeyboardVisibilityUnfocusMode.off:
        return KeyboardVisibilityUnfocusMode.lazy;
      case KeyboardVisibilityUnfocusMode.lazy:
        return KeyboardVisibilityUnfocusMode.eager;
      case KeyboardVisibilityUnfocusMode.eager:
        return null;
    }
  }
}

class _ConfigurationButtons extends StatelessWidget {
  const _ConfigurationButtons({
    required this.currentEnableUnfocusing,
    required this.currentDefaultUnfocusMode,
    required this.currentFocusNodeUnfocusMode,
    this.onUnfocusPressed,
    this.onEnableUnfocusingPressed,
    this.onDefaultUnfocusModePressed,
    this.onFocusNodeUnfocusModePressed,
  });

  final bool currentEnableUnfocusing;
  final KeyboardVisibilityUnfocusMode currentDefaultUnfocusMode;
  final KeyboardVisibilityUnfocusMode? currentFocusNodeUnfocusMode;

  /// Manually unfocus the current focus node.
  final VoidCallback? onUnfocusPressed;

  // KeyboardVisibilityUnfocuser.enableUnfocusing
  final VoidCallback? onEnableUnfocusingPressed;

  // KeyboardVisibilityUnfocuser.defaultUnfocusMode
  final VoidCallback? onDefaultUnfocusModePressed;

  // focusNode.unfocusMode
  final VoidCallback? onFocusNodeUnfocusModePressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      runSpacing: 4,
      spacing: 8,
      children: [
        ElevatedButton(
          onPressed: onUnfocusPressed,
          child: const Text('Unfocus'),
        ),
        ElevatedButton(
          onPressed: onEnableUnfocusingPressed,
          child: Text('Enable unfocusing: $currentEnableUnfocusing'),
        ),
        ElevatedButton(
          onPressed: onDefaultUnfocusModePressed,
          child: Text('Global unfocus mode: ${currentDefaultUnfocusMode.name}'),
        ),
        ElevatedButton(
          onPressed: onFocusNodeUnfocusModePressed,
          child: Text(
            'Text field unfocus mode: ${currentFocusNodeUnfocusMode?.name}',
          ),
        ),
      ],
    );
  }
}
