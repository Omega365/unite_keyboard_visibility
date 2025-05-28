import 'dart:async';

import 'package:unite_keyboard_visibility/src/keyboard_state.dart';
import 'package:unite_keyboard_visibility/src/platform/unite_keyboard_visibility_platform_interface.dart';

class UniteKeyboardVisibility {
  static UniteKeyboardVisibilityPlatform get _platformInstance =>
      UniteKeyboardVisibilityPlatform.instance;

  /// {@template UniteKeyboardVisibility.getCurrentState}
  /// Returns the current keyboard visibility state.
  /// {@endtemplate}
  KeyboardVisibilityState getCurrentState() =>
      _platformInstance.getCurrentState();

  /// {@template UniteKeyboardVisibility.getPlatformState}
  /// Queries the current keyboard visibility status from the platform.
  /// {@endtemplate}
  Future<KeyboardVisibilityState> getPlatformState() =>
      _platformInstance.getPlatformState();

  /// {@template UniteKeyboardVisibilityPlatform.watchVisibilityStates}
  /// Stream of keyboard states from the platform. The current state will be
  /// emitted immediately for any new listener.
  ///
  /// Use this when you only care about whether the keyboard is in open or close
  /// state.
  /// {@endtemplate}
  Stream<KeyboardVisibilityState> watchVisibilityStates() =>
      _platformInstance.watchVisibilityStates();

  /// {@template UniteKeyboardVisibilityPlatform.watchAnimationStates}
  /// Stream of keyboard animation states from the platform. The current state
  /// will be emitted immediately for any new listener.
  ///
  /// Use this when you want finer information about the keyboard animation.
  /// {@endtemplate}
  Stream<KeyboardAnimationState> watchAnimationStates() =>
      _platformInstance.watchAnimationStates();
}
