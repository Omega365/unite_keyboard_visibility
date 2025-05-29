import 'package:dart_mappable/dart_mappable.dart';

part 'keyboard_state.mapper.dart';

enum KeyboardVisibilityStatus {
  open,
  maybeOpen,
  close,
  maybeClose;

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
