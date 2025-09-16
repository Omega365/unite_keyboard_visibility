import 'package:rxdart/rxdart.dart';
import 'package:unite_keyboard_visibility/src/domain/keyboard_visibility_status.dart';
import 'package:unite_keyboard_visibility/src/platform/fallback/unite_keyboard_visibility_fallback.dart';
import 'package:unite_keyboard_visibility/src/platform/unite_keyboard_visibility_platform_interface.dart';

/// A class that provides methods to access the device keyboard visibility
/// status.
///
/// Example:
/// ```dart
/// // Initialize the plugin.
/// WidgetsFlutterBinding.ensureInitialized();
/// await UniteKeyboardVisibility.instance.initialize();
///
/// // Access the singleton instance.
/// final visibility = UniteKeyboardVisibility.instance;
///
/// // Get current visibility status.
/// final status = visibility.value;
/// print('Keyboard is $status');
///
/// // Listen for visibility changes.
/// visibility.valueStream.listen((status) {
///   print('Keyboard visibility changed: $status');
/// });
///
/// // When done, dispose the plugin.
/// await visibility.dispose();
/// ```
class UniteKeyboardVisibility {
  const UniteKeyboardVisibility._internal();

  static const UniteKeyboardVisibility _instance =
      UniteKeyboardVisibility._internal();

  /// The singleton instance of [UniteKeyboardVisibility].
  static UniteKeyboardVisibility get instance => _instance;

  UniteKeyboardVisibilityPlatform get _platformInstance =>
      UniteKeyboardVisibilityPlatform.instance;

  /// Initializes keyboard visibility detection.
  ///
  /// - [enableLogging]: Enables internal logging for debugging. Defaults to
  ///   `false`.
  ///
  /// - [forceFallback]: Forces the use of the fallback implementation on
  ///   Android, which may be necessary if the newer implementation does not
  ///   work correctly. iOS always uses fallback mode, so this parameter is
  ///   ignored on iOS. Note that [KeyboardVisibilityStatus.maybeClose],
  ///   [KeyboardVisibilityStatus.maybeOpen] and floating keyboard detection are
  ///   not supported in fallback mode. Defaults to `false`.
  ///
  /// If you want to re-initialize this plugin, you must call [dispose] first.
  Future<void> initialize({
    bool enableLogging = false,
    bool forceFallback = false,
  }) async {
    if (forceFallback && !_platformInstance.isInitialized) {
      UniteKeyboardVisibilityFallback.registerWith();
    }
    await _platformInstance.initialize(enableLogging: enableLogging);
  }

  /// {@macro UniteKeyboardVisibilityPlatform.dispose}
  Future<void> dispose() => _platformInstance.dispose();

  /// {@macro UniteKeyboardVisibilityPlatform.isInitialized}
  bool get isInitialized => _platformInstance.isInitialized;

  /// {@macro UniteKeyboardVisibilityPlatform.value}
  KeyboardVisibilityStatus get value => _platformInstance.value;

  /// {@macro UniteKeyboardVisibilityPlatform.valueStream}
  ValueStream<KeyboardVisibilityStatus> get valueStream =>
      _platformInstance.valueStream;
}
