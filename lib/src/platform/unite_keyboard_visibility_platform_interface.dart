import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unite_keyboard_visibility/src/domain/exceptions.dart';
import 'package:unite_keyboard_visibility/src/domain/keyboard_visibility_status.dart';

abstract class UniteKeyboardVisibilityPlatform extends PlatformInterface {
  /// Constructs a UniteKeyboardVisibilityPlatform.
  UniteKeyboardVisibilityPlatform() : super(token: _token);

  static final Object _token = Object();

  static late UniteKeyboardVisibilityPlatform _instance;

  /// The default instance of [UniteKeyboardVisibilityPlatform] to use.
  static UniteKeyboardVisibilityPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UniteKeyboardVisibilityPlatform]
  /// when they register themselves.
  static set instance(UniteKeyboardVisibilityPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // Below are the methods that must be implemented by platform-specific
  // implementations of this interface.

  /// {@template UniteKeyboardVisibilityPlatform.initialize}
  /// Initializes keyboard visibility detection.
  ///
  /// If the plugin is already initialized, this method throws a
  /// [PluginInitializedError].
  /// {@endtemplate}
  Future<void> initialize({required bool enableLogging});

  /// {@template UniteKeyboardVisibilityPlatform.dispose}
  /// Disposes the initialized plugin and releases associated resources. If the
  /// plugin is not initialized, this method does nothing.
  /// {@endtemplate}
  Future<void> dispose();

  /// {@template UniteKeyboardVisibilityPlatform.isInitialized}
  /// Whether the plugin has been initialized.
  ///
  /// If not initialized, calling other methods (except [initialize]) will throw
  /// an [PluginUninitializedError].
  /// {@endtemplate}
  bool get isInitialized;

  /// {@template UniteKeyboardVisibilityPlatform.value}
  /// The current keyboard visibility status.
  ///
  /// Throws [PluginUninitializedError] if the plugin has not been initialized.
  /// {@endtemplate}
  KeyboardVisibilityStatus get value;

  /// {@template UniteKeyboardVisibilityPlatform.valueStream}
  /// A stream of keyboard visibility status changes. The current value will be
  /// emitted immediately for any new listener.
  ///
  /// Throws [PluginUninitializedError] if the plugin has not been initialized.
  /// {@endtemplate}
  ValueStream<KeyboardVisibilityStatus> get valueStream;
}
