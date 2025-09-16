import 'dart:async';

import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unite_keyboard_visibility/src/domain/android_keyboard_state.dart';
import 'package:unite_keyboard_visibility/src/domain/exceptions.dart';
import 'package:unite_keyboard_visibility/src/domain/keyboard_visibility_status.dart';
import 'package:unite_keyboard_visibility/src/generated/messages.g.dart';
import 'package:unite_keyboard_visibility/src/platform/android/android_keyboard_animation_session.dart';
import 'package:unite_keyboard_visibility/src/platform/android/android_keyboard_api_handlers.dart';
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
  final AndroidKeyboardVisibilityHostApiClient _androidHostApi =
      AndroidKeyboardVisibilityHostApiClientPigeonAdapter(
    AndroidKeyboardVisibilityHostApi(),
  );

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

    _delegate = _UniteKeyboardVisibilityAndroidDelegate(
      logger: Logger(
        printer: SimplePrinter(colors: false, printTime: true),
        level: enableLogging ? Level.all : Level.off,
      ),
      flutterApiController: _flutterApiHandler,
      hostApiController: _androidHostApi,
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
    required Logger logger,
    required AndroidKeyboardVisibilityFlutterApiService flutterApiController,
    required AndroidKeyboardVisibilityHostApiClient hostApiController,
  })  : _logger = logger,
        _flutterApiController = flutterApiController,
        _hostApiController = hostApiController;

  /// The logger instance for logging API events.
  final Logger _logger;

  /// The Flutter API for receiving events from the native Android code.
  final AndroidKeyboardVisibilityFlutterApiService _flutterApiController;

  /// The host API for communicating with the native Android code.
  final AndroidKeyboardVisibilityHostApiClient _hostApiController;

  /// The stream controller for emitting the final keyboard visibility status.
  late final _resultStreamCtl = BehaviorSubject<KeyboardVisibilityStatus>(
    sync: true,
    onListen: () async => _hostApiController.setListenersEnabled(true),
    onCancel: () async => _hostApiController.setListenersEnabled(false),
  );

  /// Subscription to the visibility state stream from native Android.
  StreamSubscription<AndroidKeyboardVisibilityState>?
      _visibilityStreamSubscription;

  /// Subscription to the animation state stream from native Android.
  StreamSubscription<AndroidKeyboardAnimationState>?
      _animationStreamSubscription;

  /// The current active animation session, if any.
  ///
  /// Created when an animation prepare event is received and destroyed when the
  /// animation ends. Used to track and validate the animation state sequence.
  AndroidKeyboardAnimationSession? _animationSession;

  /// Handles incoming visibility state changes from the native Android side.
  void _handleNextVisibilityState(AndroidKeyboardVisibilityState nextState) {
    _logger.d(nextState);

    _animationSession?.registerVisibilityState(nextState);
    _resultStreamCtl.add(
      nextState.toKeyboardVisibilityStatus(
        isDuringAnimation: _animationSession != null,
      ),
    );
  }

  /// Handles incoming animation state changes from the native Android side.
  ///
  /// This method manages the keyboard animation lifecycle:
  ///
  /// - **Prepare Phase**: Creates a new animation session to track the
  ///   animation.
  ///
  /// - **Start/Progress/End Phases**: Registers the state with the active
  ///   session for validation and tracking.
  ///
  /// - **End Phase**: Retrieves the final animation verdict and emits it as the
  ///   result, then destroys the animation session.
  void _handleNextAnimationState(AndroidKeyboardAnimationState nextState) {
    _logger.d(nextState);

    if (nextState is AndroidKeyboardAnimationStatePrepare) {
      // Start a new animation session.
      _animationSession = AndroidKeyboardAnimationSession();
    }

    _animationSession!.registerAnimationState(nextState);

    if (nextState is AndroidKeyboardAnimationStateEnd) {
      _resultStreamCtl.add(_animationSession!.getSessionVerdict());
      // End the current animation session.
      _animationSession = null;
    }
  }

  @override
  Future<void> initialize() async {
    _logger.d('Initializing Android keyboard visibility delegate');

    _visibilityStreamSubscription = _flutterApiController.visibilityStream
        .listen(_handleNextVisibilityState);

    _animationStreamSubscription =
        _flutterApiController.animationStream.listen(_handleNextAnimationState);

    _logger.d('Querying initial keyboard state');
    _resultStreamCtl.add(
      (await _hostApiController.getVisibility()).toKeyboardVisibilityStatus(
        isDuringAnimation: _animationSession != null,
      ),
    );

    await _resultStreamCtl.first;
  }

  @override
  Future<void> dispose() async {
    await Future.wait([
      _resultStreamCtl.close(),
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
