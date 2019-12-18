package com.shekarmudaliyar.social_share

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.lang.Exception

/** SocialSharePlugin */
class SocialSharePlugin(private val registrar: Registrar):  MethodCallHandler {

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "social_share")
      channel.setMethodCallHandler(SocialSharePlugin(registrar))
    }
  }
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
      if (call.method == "shareInstagramStory") {
          try {
              val stickerImage: String? = call.argument("stickerImage")
              val backgroundTopColor: String? = call.argument("backgroundTopColor")
              val backgroundBottomColor: String? = call.argument("backgroundBottomColor")
              val attributionURL: String? = call.argument("attributionURL")
//          val file =  File(registrar.activeContext().cacheDir,stickerImagePath)
//          Log.d("log",registrar.context().packageName)
//          val stickerImage = FileProvider.getUriForFile(registrar.activeContext(), registrar.activeContext().applicationContext.packageName + ".provider", file)
//          Log.d("log",stickerImage.toString())
//
//          val intent = Intent("com.instagram.share.ADD_TO_STORY")
//          intent.type = "image/*"
//          intent.putExtra("interactive_asset_uri", Uri.parse(stickerImage))
//          intent.putExtra("content_url", attributionURL)
//          intent.putExtra("top_background_color", "#33FF33")
//          intent.putExtra("bottom_background_color", "#FF00FF")
////            intent.`package`="com.instagram.android"
//          // Instantiate activity and verify it will resolve implicit intent
//          // Instantiate activity and verify it will resolve implicit intent
//          val activity: Activity = registrar.activity()
//          activity.grantUriPermission(
//                  "com.instagram.android", Uri.parse(stickerImage), Intent.FLAG_GRANT_READ_URI_PERMISSION)
//          if (activity.packageManager.resolveActivity(intent, 0) != null) {
//              activity.startActivityForResult(intent, 0)
//          }
              val stickerAssetUri: Uri = Uri.parse(stickerImage)
              val intent = Intent("com.instagram.share.ADD_TO_STORY")
              intent.type = "image/*"
              intent.putExtra("interactive_asset_uri", stickerAssetUri)
              intent.putExtra("content_url", attributionURL)
              intent.putExtra("top_background_color", "#33FF33")
              intent.putExtra("bottom_background_color", "#FF00FF")
              Log.d("", registrar.activity().toString())
              // Instantiate activity and verify it will resolve implicit intent
              // Instantiate activity and verify it will resolve implicit intent
              val activity: Activity = registrar.activity()
              activity.grantUriPermission(
                      "com.instagram.android", stickerAssetUri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
              if (activity.packageManager.resolveActivity(intent, 0) != null) {
                  registrar.activeContext().startActivity(intent)
                  result.success("success")
              } else {
                  result.success("error")
              }
          }
          catch (e:Exception){
              Log.d("  ",e.toString())
          }
      } else {
          result.notImplemented()
      }
  }
}
