import 'dart:async';

import 'package:unite_keyboard_visibility/src/domain/android_keyboard_state.dart';
import 'package:unite_keyboard_visibility/src/generated/messages.g.dart';

/// Service interface that provides access to Android keyboard visibility and
/// animation state streams.
abstract interface class AndroidKeyboardVisibilityFlutterApiService {
  /// Stream of keyboard visibility state changes.
  Stream<AndroidKeyboardVisibilityState> get visibilityStream;

  /// Stream of keyboard animation state changes.
  Stream<AndroidKeyboardAnimationState> get animationStream;
}

/// Client interface for communicating with the Android platform host code.
abstract interface class AndroidKeyboardVisibilityHostApiClient {
  /// Enables or disables the native keyboard visibility listeners.
  ///
  /// When [enabled] is true, the native side starts listening for keyboard
  /// visibility changes and animations. When false, listeners are stopped to
  /// conserve resources.
  Future<void> setListenersEnabled(bool enabled);

  /// Queries the current keyboard visibility state from the native side.
  Future<AndroidKeyboardVisibilityState> getVisibility();
}

/// A class that handles platform event callbacks and converts them to Dart
/// streams.
///
/// This class serves as a bridge between the native Android platform code and
/// the Dart application. It implements both the
/// [AndroidKeyboardVisibilityFlutterApi] interface (to receive callbacks from
/// native code) and the [AndroidKeyboardVisibilityFlutterApiService] interface
/// (to provide streams to Dart consumers).
///
/// The handler converts platform-specific callbacks into reactive streams that
/// can be consumed by the rest of the application. It manages two separate
/// streams:
/// - Visibility stream: for keyboard open/close state changes
/// - Animation stream: for keyboard animation lifecycle events
///
/// All stream controllers use broadcast streams with synchronous delivery to
/// ensure immediate propagation of keyboard state changes.
class AndroidKeyboardVisibilityFlutterApiHandler
    implements
        AndroidKeyboardVisibilityFlutterApi,
        AndroidKeyboardVisibilityFlutterApiService {
  AndroidKeyboardVisibilityFlutterApiHandler();

  /// Stream controller for keyboard visibility state changes.
  final StreamController<AndroidKeyboardVisibilityState> _visibilityStreamCtl =
      StreamController.broadcast(sync: true);

  /// Stream controller for keyboard animation state changes.
  final StreamController<AndroidKeyboardAnimationState> _animationStreamCtl =
      StreamController.broadcast(sync: true);

  @override
  Stream<AndroidKeyboardVisibilityState> get visibilityStream =>
      _visibilityStreamCtl.stream;

  @override
  Stream<AndroidKeyboardAnimationState> get animationStream =>
      _animationStreamCtl.stream;

  @override
  void onVisibilityChanged(AndroidKeyboardVisibilityStateResponse response) {
    _visibilityStreamCtl.add(
      AndroidKeyboardVisibilityState(
        isVisible: response.isVisible,
        bottomInsetDevicePixels: response.bottomInsetDevicePixels,
      ),
    );
  }

  @override
  void onPrepare() {
    _animationStreamCtl.add(AndroidKeyboardAnimationState.onPrepare());
  }

  @override
  void onStart(int lowerBoundDevicePixels, int upperBoundDevicePixels) {
    _animationStreamCtl.add(
      AndroidKeyboardAnimationState.onStart(
        lowerBoundDevicePixels: lowerBoundDevicePixels,
        upperBoundDevicePixels: upperBoundDevicePixels,
      ),
    );
  }

  @override
  void onProgress(AndroidKeyboardVisibilityStateResponse response) {
    _animationStreamCtl.add(
      AndroidKeyboardAnimationState.onProgress(
        visibilityState: AndroidKeyboardVisibilityState(
          isVisible: response.isVisible,
          bottomInsetDevicePixels: response.bottomInsetDevicePixels,
        ),
      ),
    );
  }

  @override
  void onEnd() {
    _animationStreamCtl.add(AndroidKeyboardAnimationState.onEnd());
  }
}

/// Adapter class that implements [AndroidKeyboardVisibilityHostApiClient] using
/// the Pigeon-generated [AndroidKeyboardVisibilityHostApi].
///
/// This class serves as an adapter between the domain-specific client interface
/// and the Pigeon-generated platform channel API. It handles the conversion
/// between platform-specific response objects and domain model objects.
class AndroidKeyboardVisibilityHostApiClientPigeonAdapter
    implements AndroidKeyboardVisibilityHostApiClient {
  AndroidKeyboardVisibilityHostApiClientPigeonAdapter(this._androidHostApi);

  /// The underlying Pigeon-generated API instance that handles platform
  /// communication.
  final AndroidKeyboardVisibilityHostApi _androidHostApi;

  @override
  Future<void> setListenersEnabled(bool enabled) async {
    return _androidHostApi.setListenersEnabled(enabled);
  }

  @override
  Future<AndroidKeyboardVisibilityState> getVisibility() async {
    final rawState = await _androidHostApi.getVisibility();
    return AndroidKeyboardVisibilityState(
      isVisible: rawState.isVisible,
      bottomInsetDevicePixels: rawState.bottomInsetDevicePixels,
    );
  }
}
