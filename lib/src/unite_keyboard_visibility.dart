import 'package:rxdart/rxdart.dart';
import 'package:unite_keyboard_visibility/src/platform/unite_keyboard_visibility_platform_interface.dart';
import 'package:unite_keyboard_visibility/src/states/keyboard_state.dart';

/// A class that provides methods to access the device keyboard visibility
/// status.
///
/// Please note that **[KeyboardVisibilityStatus.maybeClose]** and
/// **[KeyboardVisibilityStatus.maybeOpen]** are currently only supported on
/// Android.
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
  /// - [enableLogging]: Enables internal logging when set to true. Useful for
  ///   debugging but may impact performance. Defaults to false.
  ///
  /// - [forceFallback]: Enable fallback mode, which forces the use of the older
  ///   implementation (`https://pub.dev/packages/flutter_keyboard_visibility`)
  ///   regardless of platform. [KeyboardVisibilityStatus.maybeClose] and
  ///   [KeyboardVisibilityStatus.maybeOpen] is not supported in fallback mode.
  ///   Defaults to false.
  static void initialize({
    bool enableLogging = false,
    bool forceFallback = false,
  }) {
    UniteKeyboardVisibilityPlatform.initialize(
      enableLogging: enableLogging,
      forceFallback: forceFallback,
    );
  }

  static UniteKeyboardVisibilityPlatform get _platformInstance =>
      UniteKeyboardVisibilityPlatform.instance;

  /// {@macro UniteKeyboardVisibilityPlatform.value}
  KeyboardVisibilityStatus get value => _platformInstance.value;

  /// {@macro UniteKeyboardVisibilityPlatform.stream}
  ValueStream<KeyboardVisibilityStatus> get valueStream =>
      _platformInstance.stream;
}
