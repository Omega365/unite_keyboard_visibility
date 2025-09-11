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


const val nativeLoggingEnabled: Boolean = false

class Utils {
  companion object {
    /**
     * Log a native event.
     */
    fun log(message: String) {
      if (nativeLoggingEnabled) {
        Log.d("UKV_Android", message)
      }
    }

    /**
     * Checks if the animation type is IME.
     */
    fun checkIsImeAnimation(animation: WindowInsetsAnimationCompat): Boolean {
      return animation.typeMask and WindowInsetsCompat.Type.ime() != 0
    }


    /**
     * Returns a [AndroidKeyboardVisibilityStateResponse] based on the current window insets.
     *
     * This method extracts the keyboard (IME) visibility and the bottom inset in pixels,
     * which represents the distance from the bottom of the screen to the top of the keyboard.
     */
    fun getKeyboardStateResponseFromInset(insets: WindowInsetsCompat): AndroidKeyboardVisibilityStateResponse {
      val imeVisible = insets.isVisible(WindowInsetsCompat.Type.ime())
      val imeHeight = insets.getInsets(WindowInsetsCompat.Type.ime()).bottom.toLong()
      return AndroidKeyboardVisibilityStateResponse(isVisible = imeVisible, imeHeight)
    }
  }
}

/** UniteKeyboardVisibilityPlugin */
class UniteKeyboardVisibilityPlugin : FlutterPlugin, ActivityAware,
  AndroidKeyboardVisibilityHostApi {
  private lateinit var flutterApi: AndroidKeyboardVisibilityFlutterApi

  private lateinit var keyboardVisibilityManager: KeyboardVisibilityManager

  // Plugin initialization starts here

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    Utils.log("onAttachedToEngine")
    flutterApi = AndroidKeyboardVisibilityFlutterApi(flutterPluginBinding.binaryMessenger)
    AndroidKeyboardVisibilityHostApi.setUp(flutterPluginBinding.binaryMessenger, this)

    keyboardVisibilityManager = KeyboardVisibilityManager(flutterApi)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    Utils.log("onDetachedFromEngine")
    AndroidKeyboardVisibilityHostApi.setUp(binding.binaryMessenger, null)
  }

  // View initialization and configuration starts here

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    Utils.log("onAttachedToActivity")
    keyboardVisibilityManager.setView(binding.activity.findViewById<View>(android.R.id.content))
  }

  override fun onDetachedFromActivity() {
    Utils.log("onDetachedFromActivity")
    keyboardVisibilityManager.setView(null)
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    Utils.log("onReattachedToActivityForConfigChanges")
    keyboardVisibilityManager.setView(binding.activity.findViewById<View>(android.R.id.content))
  }

  override fun onDetachedFromActivityForConfigChanges() {
    Utils.log("onDetachedFromActivityForConfigChanges")
    keyboardVisibilityManager.setView(null)
  }

  // KeyboardVisibilityHostApi implementation starts here

  override fun setListenersEnabled(enabled: Boolean) {
    keyboardVisibilityManager.setEnable(enabled)
  }

  override fun getVisibility(callback: (Result<AndroidKeyboardVisibilityStateResponse>) -> Unit) {
    fun reply(view: View) {
      val insets = ViewCompat.getRootWindowInsets(view)
      if (insets == null) {
        callback(Result.failure(IllegalStateException("Unable to obtain window insets from root view")))
      } else {
        callback(Result.success(Utils.getKeyboardStateResponseFromInset(insets)))
      }
    }

    keyboardVisibilityManager.currentView?.let { view -> reply(view) } ?: run {
      // Queue the request until a view becomes available.
      keyboardVisibilityManager.runWhenViewAvailable { awaitedView -> reply(awaitedView) }
    }
  }
}

class KeyboardVisibilityManager(
  /**
   * The flutter api to forward keyboard events to.
   */
  private val flutterApi: AndroidKeyboardVisibilityFlutterApi
) {
  /**
   * Flag indicating whether listeners should be attached to the current view.
   */
  private var enableListeners: Boolean = false

  /**
   * The root/content view we observe. Null until the activity is attached.
   */
  internal var currentView: View? = null
    private set

  /** Callbacks waiting for a non-null view. */
  private val onViewAvailableCallbacks = mutableListOf<(View) -> Unit>()

  /** Execute [callback] immediately if view available or queue until it is. */
  fun runWhenViewAvailable(callback: (View) -> Unit) {
    val view = currentView
    if (view != null) {
      callback(view)
    } else {
      onViewAvailableCallbacks.add(callback)
    }
  }

  /**
   * Assign a new view to observe. Will (de)register listeners automatically based on [enableListeners].
   */
  fun setView(newView: View?) {
    if (currentView === newView) return
    Utils.log("KeyboardVisibilityListenersManager.setView -> ${currentView?.hashCode()} -> ${newView?.hashCode()}")
    if (enableListeners) {
      currentView?.let { deregisterAll(it) }
      newView?.let { registerAll(it) }
    }

    if (newView != null && onViewAvailableCallbacks.isNotEmpty()) {
      // Flush queued callbacks safely.
      val callbacks = onViewAvailableCallbacks.toList()
      onViewAvailableCallbacks.clear()
      callbacks.forEach { cb ->
        try {
          cb(newView)
        } catch (t: Throwable) {
          Utils.log("Callback threw: ${t.message}")
        }
      }
    }

    currentView = newView
  }

  /**
   * Enable or disable the listeners. Safe to call repeatedly.
   */
  fun setEnable(newEnable: Boolean) {
    if (enableListeners == newEnable) return
    Utils.log("KeyboardVisibilityListenersManager.setEnable -> $enableListeners -> $newEnable")
    enableListeners = newEnable
    currentView?.let { view ->
      if (newEnable) registerAll(view) else deregisterAll(view)
    }
  }

  /** Register all listeners for the given view. */
  private fun registerAll(view: View) {
    registerImeVisibilityListener(view)
    registerImeAnimationListener(view)
  }

  /** Deregister all listeners for the given view. */
  private fun deregisterAll(view: View) {
    deregisterImeVisibilityListener(view)
    deregisterImeAnimationListener(view)
  }

  /**
   * Registers a callback on the given view to report keyboard inset visibility events.
   */
  private fun registerImeVisibilityListener(view: View) {
    Utils.log("registerImeVisibilityCallback")
    ViewCompat.setOnApplyWindowInsetsListener(view) { _, insets ->
      flutterApi.onVisibilityChanged(Utils.getKeyboardStateResponseFromInset(insets)) { _ -> }
      insets
    }
  }

  private fun deregisterImeVisibilityListener(view: View) {
    Utils.log("deregisterImeVisibilityCallback")
    ViewCompat.setOnApplyWindowInsetsListener(view, null)

  }

  /**
   * Registers a callback on the given view to report keyboard inset animation events.
   */
  private fun registerImeAnimationListener(view: View) {
    Utils.log("registerImeAnimationCallback")
    ViewCompat.setWindowInsetsAnimationCallback(
      view,
      object : WindowInsetsAnimationCompat.Callback(DISPATCH_MODE_CONTINUE_ON_SUBTREE) {
        override fun onPrepare(animation: WindowInsetsAnimationCompat) {
          if (Utils.checkIsImeAnimation(animation)) {
            flutterApi.onPrepare { _ -> }
          }
        }

        override fun onStart(
          animation: WindowInsetsAnimationCompat,
          bounds: WindowInsetsAnimationCompat.BoundsCompat,
        ): WindowInsetsAnimationCompat.BoundsCompat {
          if (Utils.checkIsImeAnimation(animation)) {
            flutterApi.onStart(
              bounds.lowerBound.bottom.toLong(), bounds.upperBound.bottom.toLong()
            ) { _ -> }
          }
          return bounds
        }

        override fun onProgress(
          insets: WindowInsetsCompat,
          runningAnimations: List<WindowInsetsAnimationCompat>,
        ): WindowInsetsCompat {
          if (runningAnimations.any { Utils.checkIsImeAnimation(it) }) {
            flutterApi.onProgress(Utils.getKeyboardStateResponseFromInset(insets)) { _ -> }
          }
          return insets
        }

        override fun onEnd(animation: WindowInsetsAnimationCompat) {
          if (Utils.checkIsImeAnimation(animation)) {
            flutterApi.onEnd { _ -> }
          }
        }
      },
    )
  }

  private fun deregisterImeAnimationListener(view: View) {
    Utils.log("deregisterImeAnimationCallback")
    ViewCompat.setWindowInsetsAnimationCallback(view, null)
  }
}
