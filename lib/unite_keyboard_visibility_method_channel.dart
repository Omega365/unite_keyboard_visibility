import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'unite_keyboard_visibility_platform_interface.dart';

/// An implementation of [UniteKeyboardVisibilityPlatform] that uses method channels.
class MethodChannelUniteKeyboardVisibility extends UniteKeyboardVisibilityPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('unite_keyboard_visibility');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
