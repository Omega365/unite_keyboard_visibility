import 'package:flutter_test/flutter_test.dart';
import 'package:unite_keyboard_visibility/unite_keyboard_visibility.dart';
import 'package:unite_keyboard_visibility/unite_keyboard_visibility_platform_interface.dart';
import 'package:unite_keyboard_visibility/unite_keyboard_visibility_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockUniteKeyboardVisibilityPlatform
    with MockPlatformInterfaceMixin
    implements UniteKeyboardVisibilityPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final UniteKeyboardVisibilityPlatform initialPlatform = UniteKeyboardVisibilityPlatform.instance;

  test('$MethodChannelUniteKeyboardVisibility is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelUniteKeyboardVisibility>());
  });

  test('getPlatformVersion', () async {
    UniteKeyboardVisibility uniteKeyboardVisibilityPlugin = UniteKeyboardVisibility();
    MockUniteKeyboardVisibilityPlatform fakePlatform = MockUniteKeyboardVisibilityPlatform();
    UniteKeyboardVisibilityPlatform.instance = fakePlatform;

    expect(await uniteKeyboardVisibilityPlugin.getPlatformVersion(), '42');
  });
}
