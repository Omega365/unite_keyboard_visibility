import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:unite_keyboard_visibility/src/domain/keyboard_visibility_status.dart';
import 'package:unite_keyboard_visibility/src/unite_keyboard_visibility.dart';
import 'package:unite_keyboard_visibility/src/widgets/keyboard_visibility_focus_node.dart';

/// A widget that manages keyboard visibility and automatically unfocuses any
/// primary focused [KeyboardVisibilityFocusNode] when the keyboard is
/// dismissed.
///
/// Wrap your app's root widget with [KeyboardVisibilityUnfocuser] to enable the
/// unfocusing behavior.
///
/// Example usage:
///
/// ```dart
/// KeyboardVisibilityUnfocuser(
///   child: MyApp(),
/// )
/// ```
class KeyboardVisibilityUnfocuser extends StatefulWidget {
  /// Constructs a widget that manages keyboard visibility and unfocusing
  /// behavior for [KeyboardVisibilityFocusNode]s.
  const KeyboardVisibilityUnfocuser({
    super.key,
    this.enableUnfocusing = true,
    this.defaultUnfocusMode = KeyboardVisibilityUnfocusMode.lazy,
    required this.child,
  });

  /// Whether to enable the unfocusing behavior.
  final bool enableUnfocusing;

  /// The default mode of unfocusing when the keyboard is hidden. You can
  /// configure each [KeyboardVisibilityFocusNode] to use a different mode by
  /// setting the [KeyboardVisibilityFocusNode.unfocusMode] property.
  final KeyboardVisibilityUnfocusMode defaultUnfocusMode;

  /// The root widget that should be wrapped with this widget.
  final Widget child;

  @override
  State<KeyboardVisibilityUnfocuser> createState() =>
      _KeyboardVisibilityUnfocuserState();
}

class _KeyboardVisibilityUnfocuserState
    extends State<KeyboardVisibilityUnfocuser> {
  StreamSubscription? _visibilitySub;
  FocusNode? _tempPreviousFocusNode;

  /// [_tempPreviousFocusNode] should be null at the start of a closing
  /// animation session. Call this to check.
  void _previousFocusNodeNullCheck() {
    if (_tempPreviousFocusNode != null) {
      throw StateError('Previous focus node is not null');
    }
  }

  void _handleEvent(FocusNode focusNode, KeyboardVisibilityStatus status) {
    final unfocusMode =
        focusNode is KeyboardVisibilityFocusNode ? focusNode.unfocusMode : null;
    final effectiveUnfocusMode = unfocusMode ?? widget.defaultUnfocusMode;

    if (effectiveUnfocusMode == KeyboardVisibilityUnfocusMode.off) {
      return;
    }

    if (effectiveUnfocusMode == KeyboardVisibilityUnfocusMode.lazy) {
      // Safe guard.
      _previousFocusNodeNullCheck();

      if (status == KeyboardVisibilityStatus.close) {
        focusNode.unfocus();
      }
      return;
    }

    if (effectiveUnfocusMode == KeyboardVisibilityUnfocusMode.eager) {
      switch (status) {
        case KeyboardVisibilityStatus.maybeClose:
          _previousFocusNodeNullCheck();
          _tempPreviousFocusNode = focusNode;
          focusNode.unfocus();

        case KeyboardVisibilityStatus.close:
          focusNode.unfocus();

        default:
          break;
      }
      return;
    }
  }

  void _initListener() {
    _visibilitySub?.cancel();
    _visibilitySub = UniteKeyboardVisibility.instance.valueStream.listen((
      visible,
    ) {
      if (visible == KeyboardVisibilityStatus.open) {
        // Restore the previous focus node if it exists.
        _tempPreviousFocusNode?.requestFocus();
        _tempPreviousFocusNode = null;
        return;
      }

      if (visible == KeyboardVisibilityStatus.close) {
        _tempPreviousFocusNode = null;
      }

      final currentFocusNode = FocusManager.instance.primaryFocus;
      if (currentFocusNode != null) {
        _handleEvent(currentFocusNode, visible);
      }
    });
  }

  @override
  void didUpdateWidget(covariant KeyboardVisibilityUnfocuser oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.enableUnfocusing && !widget.enableUnfocusing) {
      _tempPreviousFocusNode = null;
      _visibilitySub?.cancel();
      _visibilitySub = null;

      return;
    }

    if (!oldWidget.enableUnfocusing && widget.enableUnfocusing) {
      _initListener();
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.enableUnfocusing) {
      _initListener();
    }
  }

  @override
  void dispose() {
    _visibilitySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
