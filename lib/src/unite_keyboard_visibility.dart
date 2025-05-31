import 'package:rxdart/rxdart.dart';
import 'package:unite_keyboard_visibility/src/platform/unite_keyboard_visibility_platform_interface.dart';
import 'package:unite_keyboard_visibility/src/states/keyboard_state.dart';

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
  UniteKeyboardVisibility._internal();

  static final UniteKeyboardVisibility _instance =
      UniteKeyboardVisibility._internal();

  /// The singleton instance of [UniteKeyboardVisibility].
  static UniteKeyboardVisibility get instance => _instance;

  UniteKeyboardVisibilityPlatform get _platformInstance =>
      UniteKeyboardVisibilityPlatform.instance;

  bool _isInitialized = false;

  /// Whether the plugin has been initialized.
  bool get isInitialized => _isInitialized;

  /// Initializes keyboard visibility detection.
  ///
  /// Parameters:
  ///   - [enableLogging]: Enables internal logging when set to true. Useful for
  ///     debugging but may impact performance. Defaults to `false`.
  ///
  ///   - [forceFallback]: iOS always uses fallback mode, so this parameter is
  ///     ignored on iOS. On Android, it forces the use of the fallback
  ///     implementation, which may be necessary if the newer implementation
  ///     does not work correctly on some devices. Note that
  ///     [KeyboardVisibilityStatus.maybeClose],
  ///     [KeyboardVisibilityStatus.maybeOpen] and floating keyboard are not
  ///     supported in fallback mode. Defaults to `false`.
  Future<void> initialize({
    bool enableLogging = false,
    bool forceFallback = false,
  }) async {
    await _platformInstance.initialize(
      enableLogging: enableLogging,
      forceFallback: forceFallback,
    );
    _isInitialized = true;
  }

  /// Disposes the plugin and releases resources.
  Future<void> dispose() async {
    await _platformInstance.dispose();
  }

  /// Returns the current keyboard visibility.
  KeyboardVisibilityStatus get value {
    if (!_isInitialized) {
      throw _notInitializedError;
    }
    return _platformInstance.value;
  }

  /// Watch a stream of keyboard visibility. The current value will be emitted
  /// immediately for any new listener.
  ValueStream<KeyboardVisibilityStatus> get valueStream {
    if (!_isInitialized) {
      throw _notInitializedError;
    }
    return _platformInstance.stream;
  }
}

/// Error thrown when accessing plugin before initialization.
final _notInitializedError = StateError(
  'UniteKeyboardVisibility has not been initialized. '
  'Call initialize() before accessing value or valueStream.',
);
