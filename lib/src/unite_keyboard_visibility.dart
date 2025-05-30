import 'package:rxdart/rxdart.dart';
import 'package:unite_keyboard_visibility/src/platform/unite_keyboard_visibility_platform_interface.dart';
import 'package:unite_keyboard_visibility/src/states/keyboard_state.dart';

class UniteKeyboardVisibility {
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
