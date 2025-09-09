package com.vinhngt.unite_keyboard_visibility

import android.util.Log
import android.view.View
import android.content.res.Resources
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsAnimationCompat
import androidx.core.view.WindowInsetsCompat
import com.vinhngt.unite_keyboard_visibility.generated.AndroidKeyboardVisibilityFlutterApi
import com.vinhngt.unite_keyboard_visibility.generated.AndroidKeyboardVisibilityHostApi
import com.vinhngt.unite_keyboard_visibility.generated.AndroidKeyboardVisibilityStateResponse
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** UniteKeyboardVisibilityPlugin */
class UniteKeyboardVisibilityPlugin : FlutterPlugin, ActivityAware,
  AndroidKeyboardVisibilityHostApi {
  private lateinit var flutterApi: AndroidKeyboardVisibilityFlutterApi

  private val nativeLoggingEnabled: Boolean = false
  private var view: View? = null

  companion object {
    private const val TAG = "UKV_Android"
  }

  private fun log(message: String) {
    if (nativeLoggingEnabled) {
      Log.d(TAG, message)
    }
  }

  /**
   * Returns a concise description of a view for logging purposes.
   */
  private fun describeView(v: View?): String {
    if (v == null) return "<null view>"
    val cls = v::class.java.simpleName
    val hash = System.identityHashCode(v)
    val idDesc = try {
      if (v.id != View.NO_ID) {
        val entry = try {
          v.resources.getResourceEntryName(v.id)
        } catch (e: Resources.NotFoundException) {
          "res-not-found"
        }
        "@id/$entry(${v.id})"
      } else "no-id"
    } catch (e: Exception) {
      "id-error"
    }
    return "$cls#$hash $idDesc"
  }


  // Plugin initialization starts here

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    log("onAttachedToEngine")
    flutterApi = AndroidKeyboardVisibilityFlutterApi(flutterPluginBinding.binaryMessenger)
    AndroidKeyboardVisibilityHostApi.setUp(flutterPluginBinding.binaryMessenger, this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    log("onDetachedFromEngine")
    AndroidKeyboardVisibilityHostApi.setUp(binding.binaryMessenger, null)
  }

  // View initialization and configuration starts here

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    view = binding.activity.window.decorView  // capture root view.

    log("onAttachedToActivity view=${describeView(view)}")
    view?.let { setupViewListeners(it) }
//    view?.requestApplyInsets()
  }

  override fun onDetachedFromActivity() {
    log("onDetachedFromActivity cleaning view=${describeView(view)}")
    view?.let { cleanupViewListeners(it) }
    view = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    view = binding.activity.window.decorView  // recapture after config change.

    log("onReattachedToActivityForConfigChanges view=${describeView(view)}}")
    view?.let { setupViewListeners(it) }
//    view?.requestApplyInsets()
  }

  override fun onDetachedFromActivityForConfigChanges() {
    log("onDetachedFromActivityForConfigChanges cleaning view=${describeView(view)}")
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
   * Returns a [AndroidKeyboardVisibilityStateResponse] based on the current window insets.
   *
   * This method extracts the keyboard (IME) visibility and the bottom inset in pixels,
   * which represents the distance from the bottom of the screen to the top of the keyboard.
   */
  private fun getKeyboardStateResponseFromInset(
    insets: WindowInsetsCompat
  ): AndroidKeyboardVisibilityStateResponse {
    val imeVisible = insets.isVisible(WindowInsetsCompat.Type.ime())
    val imeHeight = insets.getInsets(WindowInsetsCompat.Type.ime()).bottom.toLong()
    return AndroidKeyboardVisibilityStateResponse(isVisible = imeVisible, imeHeight)
  }

  /**
   * Registers a callback on the given view to report keyboard inset animation events.
   */
  private fun registerImeAnimationCallback(view: View) {
    log("registerImeAnimationCallback for ${describeView(view)}")
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
    log("registerImeVisibilityCallback for ${describeView(view)}")
    ViewCompat.setOnApplyWindowInsetsListener(view) { _, insets ->
      flutterApi.onVisibilityChanged(getKeyboardStateResponseFromInset(insets)) { _ -> }
      insets
    }
  }

  /**
   * Registers callbacks for all keyboard events.
   */
  private fun setupViewListeners(v: View) {
    log("setupViewListeners for ${describeView(v)}")
    registerImeAnimationCallback(v)
    registerImeVisibilityCallback(v)
  }

  /**
   * Unregisters callbacks for all keyboard events to clean up resources.
   */
  private fun cleanupViewListeners(v: View) {
    log("cleanupViewListeners for ${describeView(v)}")
    ViewCompat.setWindowInsetsAnimationCallback(v, null)
    ViewCompat.setOnApplyWindowInsetsListener(v, null)
  }

  // KeyboardVisibilityHostApi implementation starts here

  override fun getVisibilityStateFromRootView(): AndroidKeyboardVisibilityStateResponse {
    val insets = view?.let { ViewCompat.getRootWindowInsets(it) }
      ?: throw IllegalStateException("Unable to get view insets")

    return getKeyboardStateResponseFromInset(insets)
  }
}
