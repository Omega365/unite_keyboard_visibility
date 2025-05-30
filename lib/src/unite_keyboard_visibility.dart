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
  UniteKeyboardVisibility._internal();

  static final UniteKeyboardVisibility _instance =
      UniteKeyboardVisibility._internal();

  static UniteKeyboardVisibility get instance => _instance;

  UniteKeyboardVisibilityPlatform get _platformInstance =>
      UniteKeyboardVisibilityPlatform.instance;

  bool _isInitialized = false;
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
  ///     [KeyboardVisibilityStatus.maybeClose] and
  ///     [KeyboardVisibilityStatus.maybeOpen] are not supported in fallback
  ///     mode. Defaults to `false`.
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
