import 'package:dart_mappable/dart_mappable.dart';

part 'keyboard_state.mapper.dart';

enum KeyboardVisibilityStatus { open, maybeOpen, close, maybeClose }

/// Represents the keyboard state.
@MappableClass()
class KeyboardVisibilityState with KeyboardVisibilityStateMappable {
  const KeyboardVisibilityState({required this.status});
  final KeyboardVisibilityStatus status;
}
