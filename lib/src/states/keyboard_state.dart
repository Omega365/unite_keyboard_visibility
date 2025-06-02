import 'package:dart_mappable/dart_mappable.dart';

part 'keyboard_state.mapper.dart';

/// Represents the keyboard visibility status.
enum KeyboardVisibilityStatus {
  /// The keyboard is fully open.
  open,

  /// The keyboard is opening, but not fully finished.
  maybeOpen,

  /// The keyboard is fully closed.
  close,

  /// The keyboard is closing but not fully finished.
  maybeClose;

  /// Graduate uncertain states to definite ones.
  ///
  /// - [maybeOpen] is treated as [open].
  /// - [maybeClose] is treated as [close].
  /// - [open] and [close] remain unchanged.
  KeyboardVisibilityStatus graduate() {
    switch (this) {
      case KeyboardVisibilityStatus.open:
        return KeyboardVisibilityStatus.open;
      case KeyboardVisibilityStatus.maybeOpen:
        return KeyboardVisibilityStatus.open;
      case KeyboardVisibilityStatus.close:
        return KeyboardVisibilityStatus.close;
      case KeyboardVisibilityStatus.maybeClose:
        return KeyboardVisibilityStatus.close;
    }
  }
}

/// Represents the keyboard state.
@MappableClass()
class KeyboardVisibilityState with KeyboardVisibilityStateMappable {
  const KeyboardVisibilityState({required this.status});
  final KeyboardVisibilityStatus status;
}
