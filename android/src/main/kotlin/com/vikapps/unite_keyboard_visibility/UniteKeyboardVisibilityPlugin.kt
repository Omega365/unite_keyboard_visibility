package com.vikapps.unite_keyboard_visibility

import android.view.View
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsAnimationCompat
import androidx.core.view.WindowInsetsCompat
import com.vikapps.unite_keyboard_visibility.generated.KeyboardVisibilityFlutterApi
import com.vikapps.unite_keyboard_visibility.generated.KeyboardVisibilityHostApi
import com.vikapps.unite_keyboard_visibility.generated.KeyboardVisibilityStateResponse
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** UniteKeyboardVisibilityPlugin */
class UniteKeyboardVisibilityPlugin : FlutterPlugin, ActivityAware, KeyboardVisibilityHostApi {
  private var view: View? = null
  private lateinit var flutterApi: KeyboardVisibilityFlutterApi

  // Plugin initialization starts here

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    flutterApi = KeyboardVisibilityFlutterApi(flutterPluginBinding.binaryMessenger)
    KeyboardVisibilityHostApi.setUp(flutterPluginBinding.binaryMessenger, this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    KeyboardVisibilityHostApi.setUp(binding.binaryMessenger, null)
  }

  // View initialization and configuration starts here

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    view = binding.activity.window.decorView  // capture root view.
    view?.let { setupViewListeners(it); it.requestApplyInsets() }
  }

  override fun onDetachedFromActivity() {
    view?.let { cleanupViewListeners(it) }
    view = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    view = binding.activity.window.decorView  // recapture after config change.
    view?.let { setupViewListeners(it); it.requestApplyInsets() }
  }

  override fun onDetachedFromActivityForConfigChanges() {
    view?.let { cleanupViewListeners(it) }
    view = null
  }

  // Helpers functions start here

  /**
   * Checks if the animation type is IME.
   */
  private fun checkIsImeAnimation(animation: WindowInsetsAnimationCompat): Boolean {
    return animation.typeMask and WindowInsetsCompat.Type.ime() != 0
  }

  /**
   * Returns a [KeyboardVisibilityStateResponse] based on the current window insets.
   *
   * This method extracts the keyboard (IME) visibility and the bottom inset in pixels,
   * which represents the distance from the bottom of the screen to the top of the keyboard.
   */
  private fun getKeyboardStateResponseFromInset(
    insets: WindowInsetsCompat
  ): KeyboardVisibilityStateResponse {
    val imeVisible = insets.isVisible(WindowInsetsCompat.Type.ime())
    val imeHeight = insets.getInsets(WindowInsetsCompat.Type.ime()).bottom.toLong()

    return KeyboardVisibilityStateResponse(isVisible = imeVisible, imeHeight)
  }

  /**
   * Registers a callback on the given view to report keyboard inset animation events.
   */
  private fun registerImeAnimationCallback(view: View) {
    ViewCompat.setWindowInsetsAnimationCallback(
      view,
      object : WindowInsetsAnimationCompat.Callback(DISPATCH_MODE_CONTINUE_ON_SUBTREE) {
        override fun onPrepare(animation: WindowInsetsAnimationCompat) {
          if (checkIsImeAnimation(animation)) {
            flutterApi.onPrepare { _ -> }
          }
        }

        override fun onStart(
          animation: WindowInsetsAnimationCompat,
          bounds: WindowInsetsAnimationCompat.BoundsCompat,
        ): WindowInsetsAnimationCompat.BoundsCompat {
          if (checkIsImeAnimation(animation)) {
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
          if (runningAnimations.any { checkIsImeAnimation(it) }) {
            flutterApi.onProgress(getKeyboardStateResponseFromInset(insets)) { _ -> }
          }
          return insets
        }

        override fun onEnd(animation: WindowInsetsAnimationCompat) {
          if (checkIsImeAnimation(animation)) {
            flutterApi.onEnd { _ -> }
          }
        }
      },
    )
  }

  /**
   * Registers a callback on the given view to report keyboard inset visibility events.
   */
  private fun registerImeVisibilityCallback(view: View) {
    ViewCompat.setOnApplyWindowInsetsListener(view) { _, insets ->
      flutterApi.onVisibilityChanged(getKeyboardStateResponseFromInset(insets)) { _ -> }
      insets
    }
  }

  /**
   * Registers callbacks for all keyboard events.
   */
  private fun setupViewListeners(v: View) {
    registerImeAnimationCallback(v)
    registerImeVisibilityCallback(v)
  }

  /**
   * Unregisters callbacks for all keyboard events to clean up resources.
   */
  private fun cleanupViewListeners(v: View) {
    ViewCompat.setWindowInsetsAnimationCallback(v, null)
    ViewCompat.setOnApplyWindowInsetsListener(v, null)
  }

  // KeyboardVisibilityHostApi implementation starts here

  override fun getCurrentState(): KeyboardVisibilityStateResponse {
    val insets = view?.let { ViewCompat.getRootWindowInsets(it) }
      ?: throw IllegalStateException("Unable to get view insets")

    return getKeyboardStateResponseFromInset(insets)
  }
}
