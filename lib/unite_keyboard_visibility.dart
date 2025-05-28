
import 'unite_keyboard_visibility_platform_interface.dart';

class UniteKeyboardVisibility {
  Future<String?> getPlatformVersion() {
    return UniteKeyboardVisibilityPlatform.instance.getPlatformVersion();
  }
}
