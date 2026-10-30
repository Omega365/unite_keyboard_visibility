import 'dart:async';

import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unite_keyboard_visibility/src/domain/android_keyboard_state.dart';
import 'package:unite_keyboard_visibility/src/domain/exceptions.dart';
import 'package:unite_keyboard_visibility/src/domain/keyboard_visibility_status.dart';
import 'package:unite_keyboard_visibility/src/generated/messages.g.dart';
import 'package:unite_keyboard_visibility/src/platform/android/android_keyboard_api_handlers.dart';
import 'package:unite_keyboard_visibility/src/platform/android/android_keyboard_state_logger.dart';
import 'package:unite_keyboard_visibility/src/platform/keyboard_visibility_delegate.dart';
import 'package:unite_keyboard_visibility/src/platform/unite_keyboard_visibility_platform_interface.dart';

class UniteKeyboardVisibilityAndroid extends UniteKeyboardVisibilityPlatform {
  /// Registers this class as the default instance of
  /// [UniteKeyboardVisibilityPlatform].
  static void registerWith() {
    UniteKeyboardVisibilityPlatform.instance = UniteKeyboardVisibilityAndroid();
  }

  /// The Flutter API for receiving events from the native Android code.
  final AndroidKeyboardVisibilityFlutterApiHandler _flutterApiHandler =
      AndroidKeyboardVisibilityFlutterApiHandler();

  /// The host API for communicating with the native Android code.
  final AndroidKeyboardVisibilityHostApiClient _hostApiClient =
      AndroidKeyboardVisibilityHostApiClientPigeonAdapter(
    AndroidKeyboardVisibilityHostApi(),
  );

  /// Special flag to enable the logging delegate for debugging purposes.
  static const bool _useLoggingDelegate = false;

  /// The delegate that handles the actual keyboard visibility detection and
  /// state management.
  KeyboardVisibilityDelegate _delegate = PluginUninitializedDelegate();

  @override
  bool get isInitialized => _delegate is! PluginUninitializedDelegate;

  @override
  Future<void> initialize({required bool enableLogging}) async {
    if (isInitialized) {
      throw PluginInitializedError();
    }

    final logger = Logger(
      printer: SimplePrinter(colors: false, printTime: true),
      level: enableLogging ? Level.all : Level.off,
    );

    _delegate = _useLoggingDelegate
        ? _UniteKeyboardVisibilityAndroidLogEventsDelegate(
            logger: logger,
            flutterApiService: _flutterApiHandler,
            hostApiClient: _hostApiClient,
          )
        : _UniteKeyboardVisibilityAndroidDelegate(
            logger: logger,
            flutterApiService: _flutterApiHandler,
            hostApiClient: _hostApiClient,
          );

    AndroidKeyboardVisibilityFlutterApi.setUp(_flutterApiHandler);
    await _delegate.initialize();
  }

  @override
  Future<void> dispose() async {
    await _delegate.dispose();
    _delegate = PluginUninitializedDelegate();
    AndroidKeyboardVisibilityFlutterApi.setUp(null);
  }

  @override
  KeyboardVisibilityStatus get value => _delegate.value;

  @override
  ValueStream<KeyboardVisibilityStatus> get valueStream =>
      _delegate.valueStream;
}

/// Internal delegate that serves as the main orchestrator for Android keyboard
/// visibility detection.
class _UniteKeyboardVisibilityAndroidDelegate
    implements KeyboardVisibilityDelegate {
  _UniteKeyboardVisibilityAndroidDelegate({
    required this._logger,
    required this._flutterApiService,
    required this._hostApiClient,
  });

  /// The logger instance for logging API events.
  final Logger _logger;

  /// The Flutter API for receiving events from the native Android code.
  final AndroidKeyboardVisibilityFlutterApiService _flutterApiService;

  /// The host API for communicating with the native Android code.
  final AndroidKeyboardVisibilityHostApiClient _hostApiClient;

  /// The stream controller for emitting the final keyboard visibility status.
  late final _resultStreamCtl = BehaviorSubject<KeyboardVisibilityStatus>(
    sync: true,
    onListen: () async => _hostApiClient.setListenersEnabled(true),
    onCancel: () async => _hostApiClient.setListenersEnabled(false),
  );

  /// The state logger for logging incoming API events.
  late final _eventLogger = AndroidKeyboardApiEventLogger(
    logger: _logger,
    flutterApiService: _flutterApiService,
  );

  /// Subscription to the visibility state stream from native Android.
  StreamSubscription<AndroidKeyboardVisibilityState>?
      _visibilityStreamSubscription;

  /// Subscription to the animation state stream from native Android.
  StreamSubscription<AndroidKeyboardAnimationState>?
      _animationStreamSubscription;

  /// Flag that indicates there is a keyboard animation running.
  ///
  /// Set to `true` when an animation prepare event is received and `false` when
  /// an onFinished event is received.
  bool _isDuringAnimation = false;

  /// Handles incoming visibility state changes from the native Android side.
  void _handleNextVisibilityState(AndroidKeyboardVisibilityState nextState) {
    _resultStreamCtl.add(
      nextState.toKeyboardVisibilityStatus(
        isDuringAnimation: _isDuringAnimation,
      ),
    );
  }

  /// Handles incoming animation state changes from the native Android side.
  void _handleNextAnimationState(AndroidKeyboardAnimationState nextState) {
    switch (nextState) {
      case AndroidKeyboardAnimationStatePrepare():
        _isDuringAnimation = true;

      case AndroidKeyboardAnimationStateEnd():
        _isDuringAnimation = false;
    }
  }

  @override
  Future<void> initialize() async {
    _logger.d('Initializing Android keyboard visibility delegate');

    _eventLogger.initialize();

    _visibilityStreamSubscription =
        _flutterApiService.visibilityStream.listen(_handleNextVisibilityState);

    _animationStreamSubscription =
        _flutterApiService.animationStream.listen(_handleNextAnimationState);

    _logger.d('Querying initial keyboard state');
    _resultStreamCtl.add(
      (await _hostApiClient.getVisibility()).toKeyboardVisibilityStatus(
        isDuringAnimation: _isDuringAnimation,
      ),
    );

    await _resultStreamCtl.first;
  }

  @override
  Future<void> dispose() async {
    await Future.wait([
      _resultStreamCtl.close(),
      _eventLogger.dispose(),
      Future.sync(() => _visibilityStreamSubscription?.cancel()),
      Future.sync(() => _animationStreamSubscription?.cancel()),
    ]);
  }

  @override
  KeyboardVisibilityStatus get value => _resultStreamCtl.value;

  @override
  late ValueStream<KeyboardVisibilityStatus> valueStream = _resultStreamCtl
      .stream
      .distinct()
      .doOnData((event) => _logger.d('Final verdict: ${event.name}'))
      .shareValue();
}

/// A delegate that logs all incoming Android keyboard API events but does not
/// perform any actual visibility detection or state management. Useful for
/// debugging events-related issues.
///
/// If you try to use this delegate to get the current keyboard visibility
/// state, it will always return [KeyboardVisibilityStatus.close] since it does
/// not track any real state.
class _UniteKeyboardVisibilityAndroidLogEventsDelegate
    implements KeyboardVisibilityDelegate {
  _UniteKeyboardVisibilityAndroidLogEventsDelegate({
    required this._logger,
    required this._flutterApiService,
    required this._hostApiClient,
  });

  /// The logger instance for logging API events.
  final Logger _logger;

  /// The Flutter API for receiving events from the native Android code.
  final AndroidKeyboardVisibilityFlutterApiService _flutterApiService;

  /// The host API for communicating with the native Android code.
  final AndroidKeyboardVisibilityHostApiClient _hostApiClient;

  /// The state logger for logging incoming API events.
  late final _eventLogger = AndroidKeyboardApiEventLogger(
    logger: _logger,
    flutterApiService: _flutterApiService,
  );

  @override
  Future<void> initialize() async {
    _eventLogger.initialize();
    await _hostApiClient.setListenersEnabled(true);
  }

  @override
  Future<void> dispose() async {
    await _hostApiClient.setListenersEnabled(false);
    await _eventLogger.dispose();
  }

  @override
  KeyboardVisibilityStatus get value => KeyboardVisibilityStatus.close;

  @override
  ValueStream<KeyboardVisibilityStatus> valueStream =
      BehaviorSubject.seeded(KeyboardVisibilityStatus.close);
}
