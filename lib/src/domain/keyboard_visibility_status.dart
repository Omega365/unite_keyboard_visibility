/// Represents the keyboard visibility status.
enum KeyboardVisibilityStatus {
  /// The keyboard is fully open.
  open,

  /// The keyboard is opening, but not fully finished.
  maybeOpen,

  /// The keyboard is fully closed.
  close,

  /// The keyboard is closing but not fully finished.
  maybeClose;

  /// Graduate uncertain states to definite ones.
  ///
  /// - [maybeOpen] is treated as [open].
  /// - [maybeClose] is treated as [close].
  /// - [open] and [close] remain unchanged.
  @Deprecated('No longer in use. Will be removed in future versions.')
  KeyboardVisibilityStatus graduate() {
    switch (this) {
      case KeyboardVisibilityStatus.open:
        return KeyboardVisibilityStatus.open;
      case KeyboardVisibilityStatus.maybeOpen:
        return KeyboardVisibilityStatus.open;
      case KeyboardVisibilityStatus.close:
        return KeyboardVisibilityStatus.close;
      case KeyboardVisibilityStatus.maybeClose:
        return KeyboardVisibilityStatus.close;
    }
  }
}
