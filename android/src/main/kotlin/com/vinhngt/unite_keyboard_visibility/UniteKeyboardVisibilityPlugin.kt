package com.vinhngt.unite_keyboard_visibility

import android.util.Log
import android.view.View
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsAnimationCompat
import androidx.core.view.WindowInsetsCompat
import com.vinhngt.unite_keyboard_visibility.generated.AndroidKeyboardVisibilityFlutterApi
import com.vinhngt.unite_keyboard_visibility.generated.AndroidKeyboardVisibilityHostApi
import com.vinhngt.unite_keyboard_visibility.generated.AndroidKeyboardVisibilityStateResponse
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import kotlin.coroutines.Continuation
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch


// Toggle native logging here. Keep false for release builds.
private const val NATIVE_LOGGING_ENABLED: Boolean = false
private const val LOG_TAG: String = "UKV_Android"

// Lightweight logger wrapper
private object Logger {
  inline fun debug(message: () -> String) {
    if (NATIVE_LOGGING_ENABLED) Log.d(LOG_TAG, message())
  }
}

// WindowInsets helpers
private fun WindowInsetsAnimationCompat.isIme(): Boolean =
  (typeMask and WindowInsetsCompat.Type.ime()) != 0

private fun WindowInsetsCompat.toKeyboardState(): AndroidKeyboardVisibilityStateResponse {
  val visible = isVisible(WindowInsetsCompat.Type.ime())
  val height = getInsets(WindowInsetsCompat.Type.ime()).bottom.toLong()
  return AndroidKeyboardVisibilityStateResponse(visible, height)
}


/**
 * Handles keyboard visibility tracking using WindowInsets listeners and animation callbacks.
 */
class KeyboardVisibilityTracker(
  private val flutterApi: AndroidKeyboardVisibilityFlutterApi
) {
  private var isListeningEnabled = false
  private var rootView: View? = null

  private val pendingContinuations =
    mutableListOf<Continuation<AndroidKeyboardVisibilityStateResponse>>()

  fun dispose() {
    rootView = null
    // Resume all pending coroutines with a cancellation exception before clearing.
    val continuationsToCancel = pendingContinuations.toList()
    pendingContinuations.clear()
    continuationsToCancel.forEach { continuation ->
      continuation.resumeWithException(IllegalStateException("Plugin detached while waiting for view"))
    }
  }

  fun setListenersEnabled(enabled: Boolean) {
    Logger.debug { "KeyboardVisibilityTracker.setListenersEnabled -> $enabled" }

    if (isListeningEnabled == enabled) {
      Logger.debug { "Listeners already in desired state: $enabled" }
      return
    }

    isListeningEnabled = enabled

    val view = rootView
    if (view != null) {
      if (enabled) {
        attachListeners(view)
      } else {
        detachListeners(view)
      }
    }
  }

  private fun tryGetCurrentState(view: View): AndroidKeyboardVisibilityStateResponse? {
    if (!view.isAttachedToWindow) {
      return null
    }
    val windowInsets = ViewCompat.getRootWindowInsets(view) ?: return null
    return windowInsets.toKeyboardState()
  }

  fun setRootView(view: View?) {
    Logger.debug { "KeyboardVisibilityTracker.setRootView -> ${view != null}" }

    // Detach from previous view if any
    rootView?.let { oldView ->
      detachListeners(oldView)
    }

    rootView = view

    // Resume pending continuations with current state if view is available
    if (view != null && pendingContinuations.isNotEmpty()) {
      val continuationsToResume = pendingContinuations.toList()
      pendingContinuations.clear()

      val currentState = tryGetCurrentState(view)
      if (currentState != null) {
        continuationsToResume.forEach { continuation ->
          continuation.resume(currentState)
        }
      } else {
        // If we can't get the state yet, add them back to pending
        pendingContinuations.addAll(continuationsToResume)
      }
    }

    // Attach to new view if listeners are enabled
    if (view != null && isListeningEnabled) {
      attachListeners(view)
    }
  }

  private fun attachListeners(view: View) {
    Logger.debug { "Attaching keyboard visibility listeners" }

    // Apply listeners to the view
    ViewCompat.setOnApplyWindowInsetsListener(view) { _, insets ->
      Logger.debug { "OnApplyWindowInsetsListener triggered" }
      val currentState = insets.toKeyboardState()

      Logger.debug { "Keyboard state: visible=${currentState.isVisible}, height=${currentState.bottomInsetDevicePixels}" }
      flutterApi.onVisibilityChanged(currentState) {
        Logger.debug { "Flutter onVisibilityChanged callback completed" }
      }

      insets
    }

    ViewCompat.setWindowInsetsAnimationCallback(
      view, object : WindowInsetsAnimationCompat.Callback(DISPATCH_MODE_CONTINUE_ON_SUBTREE) {

        override fun onPrepare(animation: WindowInsetsAnimationCompat) {
          Logger.debug { "Animation onPrepare" }
          if (animation.isIme()) {
            flutterApi.onPrepare {
              Logger.debug { "Flutter onPrepare callback completed" }
            }
          }
        }

        override fun onStart(
          animation: WindowInsetsAnimationCompat, bounds: WindowInsetsAnimationCompat.BoundsCompat
        ): WindowInsetsAnimationCompat.BoundsCompat {
          Logger.debug { "Animation onStart" }
          if (animation.isIme()) {
            val lowerBound = bounds.lowerBound.bottom.toLong()
            val upperBound = bounds.upperBound.bottom.toLong()
            flutterApi.onStart(lowerBound, upperBound) {
              Logger.debug { "Flutter onStart callback completed" }
            }
          }
          return bounds
        }

        override fun onProgress(
          insets: WindowInsetsCompat, runningAnimations: List<WindowInsetsAnimationCompat>
        ): WindowInsetsCompat {
          Logger.debug { "Animation onProgress" }

          // Check if any running animation is for IME
          val hasImeAnimation = runningAnimations.any { it.isIme() }
          if (hasImeAnimation) {
            val state = insets.toKeyboardState()
            flutterApi.onProgress(state) {
              Logger.debug { "Flutter onProgress callback completed" }
            }
          }

          return insets
        }

        override fun onEnd(animation: WindowInsetsAnimationCompat) {
          Logger.debug { "Animation onEnd" }
          if (animation.isIme()) {
            flutterApi.onEnd {
              Logger.debug { "Flutter onEnd callback completed" }
            }

            // Let Flutter know about the state after animation.
            view.requestApplyInsets()
          }
        }
      })
  }

  private fun detachListeners(view: View) {
    Logger.debug { "Detaching keyboard visibility listeners" }

    // Remove listeners from the view
    ViewCompat.setOnApplyWindowInsetsListener(view, null)
    ViewCompat.setWindowInsetsAnimationCallback(view, null)
  }

  fun getCurrentState(): AndroidKeyboardVisibilityStateResponse? {
    val view = rootView ?: return null
    return tryGetCurrentState(view)
  }

  suspend fun awaitCurrentState(): AndroidKeyboardVisibilityStateResponse =
    suspendCoroutine { continuation ->
      val currentView = rootView

      if (currentView == null) {
        pendingContinuations.add(continuation)
        return@suspendCoroutine
      }

      val currentState = tryGetCurrentState(currentView)
      if (currentState != null) {
        continuation.resume(currentState)
      } else {
        Logger.debug { "Root view is not attached to window or unable to get window insets" }
        continuation.resumeWithException(IllegalStateException("Root view is not attached to window or unable to get window insets"))
      }
    }
}

// TODO: Split UniteKeyboardVisibilityPlugin to multiple singleton.

/** UniteKeyboardVisibilityPlugin (public entry point) */
class UniteKeyboardVisibilityPlugin : FlutterPlugin, ActivityAware,
  AndroidKeyboardVisibilityHostApi {

  private lateinit var flutterApi: AndroidKeyboardVisibilityFlutterApi
  private lateinit var keyboardTracker: KeyboardVisibilityTracker

  // FlutterPlugin
  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    Logger.debug { "onAttachedToEngine" }
    flutterApi = AndroidKeyboardVisibilityFlutterApi(binding.binaryMessenger)
    keyboardTracker = KeyboardVisibilityTracker(flutterApi)
    AndroidKeyboardVisibilityHostApi.setUp(binding.binaryMessenger, this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    Logger.debug { "onDetachedFromEngine" }
    AndroidKeyboardVisibilityHostApi.setUp(binding.binaryMessenger, null)
    keyboardTracker.dispose()
  }

  // ActivityAware
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    Logger.debug { "onAttachedToActivity" }
    keyboardTracker.setRootView(binding.activity.window.decorView)
  }

  override fun onDetachedFromActivity() {
    Logger.debug { "onDetachedFromActivity" }
    keyboardTracker.setRootView(null)
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    Logger.debug { "onReattachedToActivityForConfigChanges" }
    keyboardTracker.setRootView(binding.activity.window.decorView)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    Logger.debug { "onDetachedFromActivityForConfigChanges" }
    keyboardTracker.setRootView(null)
  }

  // Pigeon Host API
  override fun setListenersEnabled(enabled: Boolean) {
    Logger.debug { "setListenersEnabled -> $enabled" }
    keyboardTracker.setListenersEnabled(enabled)
  }

  override fun getVisibility(callback: (Result<AndroidKeyboardVisibilityStateResponse>) -> Unit) {
    Logger.debug { "getVisibility called" }

    CoroutineScope(Dispatchers.Main).launch {
      try {
        val keyboardState = keyboardTracker.awaitCurrentState()
        callback(Result.success(keyboardState))
      } catch (exception: Exception) {
        Logger.debug { "Exception in getVisibility: ${exception.message}" }
        callback(Result.failure(exception))
      }
    }
  }
}
