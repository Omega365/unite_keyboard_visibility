import 'package:flutter/widgets.dart';
import 'package:unite_keyboard_visibility/src/states/keyboard_state.dart';
import 'package:unite_keyboard_visibility/src/unite_keyboard_visibility.dart';

/// Signature for [KeyboardVisibilityBuilder] builder callback.
typedef KeyboardVisibilityBuilderCallback = Widget Function(
  BuildContext context,
  KeyboardVisibilityStatus status,
  Widget? child,
);

/// A widget that rebuilds when the device keyboard visibility changes.
class KeyboardVisibilityBuilder extends StatelessWidget {
  /// Creates a widget that rebuilds when the keyboard visibility changes.
  const KeyboardVisibilityBuilder({
    super.key,
    required this.builder,
    this.child,
  });

  /// Called to build the widget tree when keyboard visibility changes.
  final KeyboardVisibilityBuilderCallback builder;

  /// Optional child widget to pass through to the builder for better
  /// performance.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: UniteKeyboardVisibility.instance.valueStream.skip(1),
      initialData: UniteKeyboardVisibility.instance.value,
      builder: (context, snapshot) {
        return builder(context, snapshot.data!, child);
      },
    );
  }
}
