import 'package:unite_keyboard_visibility/src/states/android_keyboard_state.dart';

const _reportMessage =
    'This should never happen, '
    'if you encounter this then it\'s either a bug in the plugin '
    'or the operating system behaves in a way that is not expected. '
    'Please take a look at the plugin\'s issue tracker '
    'for possible workarounds and report this issue '
    'if it\'s not already reported.';

class AndroidKeyboardVisibilityStateContractViolation extends Error {
  /// Creates an error indicating a contract violation in the Android keyboard
  /// state handling.
  AndroidKeyboardVisibilityStateContractViolation({
    required this.previousVisibilityState,
    required this.previousAnimationState,
    required this.nextVisibilityState,
  });

  final AndroidKeyboardVisibilityState? previousVisibilityState;
  final AndroidKeyboardAnimationState? previousAnimationState;
  final AndroidKeyboardVisibilityState nextVisibilityState;

  @override
  String toString() =>
      'Unexpected android keyboard visibility state received:\n\n'
      'Previous visibility state: $previousVisibilityState\n'
      'Previous animation state: $previousAnimationState\n'
      'Next visibility state: $nextVisibilityState\n\n'
      '$_reportMessage';
}

class AndroidKeyboardAnimationStateContractViolation extends Error {
  /// Creates an error indicating a contract violation in the Android keyboard
  /// animation state handling.
  AndroidKeyboardAnimationStateContractViolation({
    required this.previousVisibilityState,
    required this.previousAnimationState,
    required this.nextAnimationState,
  });

  final AndroidKeyboardVisibilityState? previousVisibilityState;
  final AndroidKeyboardAnimationState? previousAnimationState;
  final AndroidKeyboardAnimationState nextAnimationState;

  @override
  String toString() =>
      'Unexpected android keyboard animation state received:\n\n'
      'Previous visibility state: $previousVisibilityState\n'
      'Previous animation state: $previousAnimationState\n'
      'Next animation state: $nextAnimationState\n\n'
      '$_reportMessage';
}
