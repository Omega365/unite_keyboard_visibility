import 'package:rxdart/rxdart.dart';
import 'package:unite_keyboard_visibility/src/platform/unite_keyboard_visibility_platform_interface.dart';
import 'package:unite_keyboard_visibility/src/states/keyboard_state.dart';

class UniteKeyboardVisibility {
  static UniteKeyboardVisibilityPlatform get _platformInstance =>
      UniteKeyboardVisibilityPlatform.instance;

  /// Returns the current keyboard visibility.
  KeyboardVisibilityStatus get current => _platformInstance.current.status;

  /// Watch a stream of keyboard visibility. The current value will be emitted
  /// immediately for any new listener.
  ValueStream<KeyboardVisibilityStatus> watch() =>
      _platformInstance.watch().map((state) => state.status).shareValue();
}
