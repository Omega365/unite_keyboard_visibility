import 'package:rxdart/rxdart.dart';
import 'package:unite_keyboard_visibility/src/domain/exceptions.dart';
import 'package:unite_keyboard_visibility/src/domain/keyboard_visibility_status.dart';
import 'package:unite_keyboard_visibility/src/platform/unite_keyboard_visibility_platform_interface.dart';

/// Interface for the delegate that handles keyboard visibility business logic.
///
/// When an [UniteKeyboardVisibilityPlatform] implementation is initialized, it
/// should create an instance of a class that implements this interface to
/// handle the actual keyboard visibility detection and state management.
abstract interface class KeyboardVisibilityDelegate {
  KeyboardVisibilityStatus get value;
  ValueStream<KeyboardVisibilityStatus> get valueStream;

  Future<void> initialize();
  Future<void> dispose();
}

/// A delegate that throws [PluginUninitializedError] for all operations.
///
/// This is used as a placeholder before the actual delegate is initialized.
class PluginUninitializedDelegate implements KeyboardVisibilityDelegate {
  @override
  KeyboardVisibilityStatus get value => throw PluginUninitializedError();

  @override
  ValueStream<KeyboardVisibilityStatus> get valueStream =>
      throw PluginUninitializedError();

  @override
  Future<void> dispose() => throw PluginUninitializedError();

  @override
  Future<void> initialize() => throw PluginUninitializedError();
}
