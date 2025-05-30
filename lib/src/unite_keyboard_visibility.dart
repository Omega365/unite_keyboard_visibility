import 'package:rxdart/rxdart.dart';
import 'package:unite_keyboard_visibility/src/platform/unite_keyboard_visibility_platform_interface.dart';
import 'package:unite_keyboard_visibility/src/states/keyboard_state.dart';

/// A class that provides methods to access the device keyboard visibility
/// status.
///
/// Example:
/// ```dart
/// // Ensure widget binding is initialized
/// WidgetsFlutterBinding.ensureInitialized();
///
/// // Initialize the plugin (enable logging if needed)
/// UniteKeyboardVisibility.initialize(enableLogging: true);
///
/// // Create an instance to access keyboard visibility
/// final visibility = UniteKeyboardVisibility();
///
/// // Get current visibility status
/// final status = visibility.value;
///
/// // Listen for visibility changes
/// visibility.valueStream.listen((status) {
///   print('Keyboard visibility changed: $status');
/// });
/// ```
class UniteKeyboardVisibility {
  /// Initializes keyboard visibility detection.
  ///
  /// - [enableLogging] enables verbose internal logging when set to true.
  ///   Useful for debugging but may impact performance.
  static void initialize({bool enableLogging = false}) {
    UniteKeyboardVisibilityPlatform.initialize(enableLogging: enableLogging);
  }

  static UniteKeyboardVisibilityPlatform get _platformInstance =>
      UniteKeyboardVisibilityPlatform.instance;

  /// {@macro UniteKeyboardVisibilityPlatform.value}
  KeyboardVisibilityStatus get value => _platformInstance.value;

  /// {@macro UniteKeyboardVisibilityPlatform.stream}
  ValueStream<KeyboardVisibilityStatus> get valueStream =>
      _platformInstance.stream;
}
