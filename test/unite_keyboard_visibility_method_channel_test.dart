import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unite_keyboard_visibility/unite_keyboard_visibility_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelUniteKeyboardVisibility platform = MethodChannelUniteKeyboardVisibility();
  const MethodChannel channel = MethodChannel('unite_keyboard_visibility');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
