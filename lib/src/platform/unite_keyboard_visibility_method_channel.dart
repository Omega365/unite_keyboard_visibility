import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unite_keyboard_visibility/src/generated/messages.g.dart';
import 'package:unite_keyboard_visibility/src/keyboard_state.dart';
import 'package:unite_keyboard_visibility/src/platform/unite_keyboard_visibility_platform_interface.dart';

/// An implementation of [UniteKeyboardVisibilityPlatform] that uses method
/// channels.
class MethodChannelUniteKeyboardVisibility
    extends UniteKeyboardVisibilityPlatform {
  /// Unnamed factory constructor for [UniteKeyboardVisibilityPlatform] to
  /// use.
  @protected
  MethodChannelUniteKeyboardVisibility() {
    // For native to Flutter communication.
    KeyboardVisibilityFlutterApi.setUp(
      _FlutterApiHandler(_visibilitySubj, _animationSubj),
    );

    // Wait one frame to check if any keyboard event was emitted by the
    // platform. If not, query and emit the initial visibility state.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      late final KeyboardVisibilityState status;

      if (!_visibilitySubj.hasValue || !_animationSubj.hasValue) {
        status = await getPlatformState();
      } else {
        return;
      }

      // We need to check hasValue of _visibilitySubj and _animationSubj again
      // due to async gap.

      if (!_visibilitySubj.hasValue) {
        _visibilitySubj.add(status);
      }

      if (!_animationSubj.hasValue) {
        _animationSubj.add(KeyboardAnimationStateEnd());
      }
    });
  }

  // For Flutter to native communication.
  final _api = KeyboardVisibilityHostApi();

  final _visibilitySubj = BehaviorSubject<KeyboardVisibilityState>();
  final _animationSubj = BehaviorSubject<KeyboardAnimationState>();

  @override
  KeyboardVisibilityState getCurrentState() {
    if (_visibilitySubj.hasValue) {
      return _visibilitySubj.value;
    }

    throw StateError('No keyboard state has been emitted by the platform yet.');
  }

  @override
  Future<KeyboardVisibilityState> getPlatformState() async {
    final response = await _api.getCurrentState();
    return KeyboardVisibilityState.fromResponse(response);
  }

  @override
  Stream<KeyboardVisibilityState> watchVisibilityStates() =>
      _visibilitySubj.stream;

  @override
  Stream<KeyboardAnimationState> watchAnimationStates() =>
      _animationSubj.stream;
}

/// Internal implementation of [KeyboardVisibilityFlutterApi] to handle platform
/// callbacks.
class _FlutterApiHandler implements KeyboardVisibilityFlutterApi {
  _FlutterApiHandler(this._visibilitySubj, this._animationSubj);

  final BehaviorSubject<KeyboardVisibilityState> _visibilitySubj;
  final BehaviorSubject<KeyboardAnimationState> _animationSubj;

  @override
  void onVisibilityChanged(KeyboardVisibilityStateResponse response) {
    _visibilitySubj.add(KeyboardVisibilityState.fromResponse(response));
  }

  @override
  void onPrepare() {
    _animationSubj.add(KeyboardAnimationStatePrepare());
  }

  @override
  void onStart(int lowerBoundDevicePixels, int upperBoundDevicePixels) {
    _animationSubj.add(
      KeyboardAnimationStateStart(
        lowerBoundDevicePixels: lowerBoundDevicePixels,
        upperBoundDevicePixels: upperBoundDevicePixels,
      ),
    );
  }

  @override
  void onProgress(KeyboardVisibilityStateResponse response) {
    _animationSubj.add(
      KeyboardAnimationStateProgress(
        keyboardState: KeyboardVisibilityState.fromResponse(response),
      ),
    );
  }

  @override
  void onEnd() {
    _animationSubj.add(KeyboardAnimationStateEnd());
  }
}
