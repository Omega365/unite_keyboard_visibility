## [0.4.1] - 2025-09-25
### Fixed
- Fix visibility detection failing on Android 10 (API 29) and below.
- Improve detection accuracy on Android 11 (API 30) and above.

## [0.4.0] - 2025-09-16
### Changed
- Bump `sdk` to `^3.3.0` and `flutter` to `>=3.19.0`.
- Drop `meta` to `^1.11.0` to support Flutter `3.19.0` and above.

### Deprecated
- Deprecate `KeyboardVisibilityStatus.graduate` since it is no longer in use.

### Fixed
- Fix a rare race condition on Android that causes the app to crash when the plugin initializes before the Flutter activity starts.

## [0.3.0] - 2025-06-14
### Changed
- Drop `dart_mappable` constraint to `^4.3.1`.

## [0.2.4] - 2025-06-07
### Changed
- Use `const MyApp()` in README.md examples.
- Minor code refactor.

## [0.2.3] - 2025-06-04
### Changed
- Fix broken changelog links.

## [0.2.2] - 2025-06-04
### Changed
- Update README.md regarding `KeyboardVisibilityFocusNode`.

## [0.2.1] - 2025-06-03
### Changed
- Update README.md.

## [0.2.0] - 2025-06-02
### Added
- Add `KeyboardVisibilityUnfocuser`.
- Add `KeyboardVisibilityBuilder`.

## [0.1.2] - 2025-06-01
### Changed
- Update README.md.

## [0.1.1] - 2025-06-01
### Changed
- Update README.md.

## [0.1.0] - 2025-06-01
### Changed
- Update the included example.
- Update documentation.
- Switch to `flutter_keyboard_visibility_temp_fork` as the fallback implementation.

## [0.0.2] - 2025-05-31
### Changed
- Update README.md.

## [0.0.1] - 2025-05-28
### Added
- Initial release.

[0.4.1]: https://github.com/VinhNgT/unite_keyboard_visibility/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/VinhNgT/unite_keyboard_visibility/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/VinhNgT/unite_keyboard_visibility/compare/v0.2.4...v0.3.0
[0.2.4]: https://github.com/VinhNgT/unite_keyboard_visibility/compare/v0.2.3...v0.2.4
[0.2.3]: https://github.com/VinhNgT/unite_keyboard_visibility/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/VinhNgT/unite_keyboard_visibility/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/VinhNgT/unite_keyboard_visibility/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/VinhNgT/unite_keyboard_visibility/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/VinhNgT/unite_keyboard_visibility/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/VinhNgT/unite_keyboard_visibility/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/VinhNgT/unite_keyboard_visibility/compare/v0.0.2...v0.1.0
[0.0.2]: https://github.com/VinhNgT/unite_keyboard_visibility/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/VinhNgT/unite_keyboard_visibility/releases/tag/v0.0.1
