import 'package:pigeon/pigeon.dart';

class AndroidKeyboardVisibilityStateResponse {
  const AndroidKeyboardVisibilityStateResponse({
    required this.isVisible,
    required this.bottomInsetDevicePixels,
  });

  final bool isVisible;
  final int bottomInsetDevicePixels;
}

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/generated/messages.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/com/vikapps/unite_keyboard_visibility/generated/Messages.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.vikapps.unite_keyboard_visibility.generated',
    ),
    dartPackageName: 'com.vikapps.unite_keyboard_visibility',
  ),
)
@HostApi()
abstract class AndroidKeyboardVisibilityHostApi {
  AndroidKeyboardVisibilityStateResponse getVisibilityStateFromRootView();
}

@FlutterApi()
abstract class AndroidKeyboardVisibilityFlutterApi {
  /// Called when the keyboard visibility changes.
  void onVisibilityChanged(AndroidKeyboardVisibilityStateResponse response);

  /// Called when a keyboard animation is preparing to start.
  void onPrepare();

  /// Called when a keyboard animation starts.
  void onStart(int lowerBoundDevicePixels, int upperBoundDevicePixels);

  /// Called when a keyboard animation is in progress.
  void onProgress(AndroidKeyboardVisibilityStateResponse response);

  /// Called when a keyboard animation ends.
  void onEnd();
}
