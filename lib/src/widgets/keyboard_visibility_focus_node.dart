import 'package:flutter/widgets.dart';
import 'package:unite_keyboard_visibility/src/states/keyboard_state.dart';
import 'package:unite_keyboard_visibility/src/widgets/keyboard_visibility_unfocuser.dart';

/// The mode that determines how and when a [FocusNode] should unfocus when the
/// keyboard is hidden.
enum KeyboardVisibilityUnfocusMode {
  /// Unfocuses as soon as the keyboard is in
  /// [KeyboardVisibilityStatus.maybeClose]. And refocuses immediately if the
  /// keyboard returns to [KeyboardVisibilityStatus.open].
  eager,

  /// Unfocuses only after the keyboard is fully closed.
  lazy,

  /// Disables automatic unfocusing for the node.
  off,
}

/// A [FocusNode] that provides individual configurable unfocusing behavior for
/// [KeyboardVisibilityUnfocuser] to use when the keyboard is hidden.
class KeyboardVisibilityFocusNode extends FocusNode {
  /// Creates a [KeyboardVisibilityFocusNode] that can automatically unfocus
  /// when the keyboard is hidden.
  KeyboardVisibilityFocusNode({
    this.unfocusMode,
    super.debugLabel,
    super.onKeyEvent,
    super.skipTraversal = false,
    super.canRequestFocus = true,
    super.descendantsAreFocusable = true,
    super.descendantsAreTraversable = true,
  });

  /// The mode of unfocusing when the keyboard is hidden. If null, it will use
  /// the default mode defined at the root
  /// [KeyboardVisibilityUnfocuser.defaultUnfocusMode].
  KeyboardVisibilityUnfocusMode? unfocusMode;
}
