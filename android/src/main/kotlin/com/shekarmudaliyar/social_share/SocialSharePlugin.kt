package com.shekarmudaliyar.social_share

import android.app.Activity
import android.content.*
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.File

/** SocialSharePlugin */
class SocialSharePlugin(private val registrar: Registrar) : MethodCallHandler {

    @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "shareInstagramStory" -> {
                val stickerImage: String? = call.argument("stickerImage")
                val backgroundImage: String? = call.argument("backgroundImage")
                val backgroundTopColor: String? = call.argument("backgroundTopColor")
                val backgroundBottomColor: String? = call.argument("backgroundBottomColor")
                val attributionURL: String? = call.argument("attributionURL")

                val activity: Activity = registrar.activity()
                Log.d(TAG, "$activity")

                val intent = Intent("com.instagram.share.ADD_TO_STORY")
                intent.type = "image/*"
                intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                intent.putExtra("content_url", attributionURL)
                intent.putExtra("top_background_color", backgroundTopColor)
                intent.putExtra("bottom_background_color", backgroundBottomColor)

                if (stickerImage != null) {
                    val file = File(activity.cacheDir, stickerImage)
                    val uri = FileProvider.getUriForFile(
                        activity,
                        "${activity.packageName}.com.shekarmudaliyar.social_share",
                        file,
                    )
                    activity.grantUriPermission(
                        "com.instagram.android",
                        uri,
                        Intent.FLAG_GRANT_READ_URI_PERMISSION,
                    )
                    intent.putExtra("interactive_asset_uri", uri)
                }

                if (backgroundImage != null) {
                    val file = File(activity.cacheDir, backgroundImage)
                    val uri = FileProvider.getUriForFile(
                        activity,
                        "${activity.packageName}.com.shekarmudaliyar.social_share",
                        file,
                    )
                    activity.grantUriPermission(
                        "com.instagram.android",
                        uri,
                        Intent.FLAG_GRANT_READ_URI_PERMISSION,
                    )
                    intent.setDataAndType(uri, "image/*")
                }

                try {
                    activity.startActivity(intent)
                } catch (e: Exception) {
                    result.success("error")
                    Log.e(TAG, "error", e)
                    return
                }
                result.success("success")
            }
            "shareFacebookStory" -> {
                val stickerImage: String? = call.argument("stickerImage")
                val backgroundTopColor: String? = call.argument("backgroundTopColor")
                val backgroundBottomColor: String? = call.argument("backgroundBottomColor")
                val attributionURL: String? = call.argument("attributionURL")
                val appId: String? = call.argument("appId")

                val activity: Activity = registrar.activity()
                Log.d(TAG, "$activity")

                val intent = Intent("com.facebook.stories.ADD_TO_STORY")
                intent.type = "image/*"
                intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                intent.putExtra("com.facebook.platform.extra.APPLICATION_ID", appId)
                intent.putExtra("content_url", attributionURL)
                intent.putExtra("top_background_color", backgroundTopColor)
                intent.putExtra("bottom_background_color", backgroundBottomColor)

                if (stickerImage != null) {
                    val file = File(activity.cacheDir, stickerImage)
                    val uri = FileProvider.getUriForFile(
                        activity,
                        "${activity.packageName}.com.shekarmudaliyar.social_share",
                        file,
                    )
                    intent.putExtra("interactive_asset_uri", uri)
                    activity.grantUriPermission(
                        "com.facebook.katana",
                        uri,
                        Intent.FLAG_GRANT_READ_URI_PERMISSION
                    )
                }

                try {
                    activity.startActivity(intent)
                } catch (e: Exception) {
                    result.success("error")
                    Log.e(TAG, "error", e)
                    return
                }
                result.success("success")
            }
            "shareOptions" -> {
                val content: String? = call.argument("content")
                val image: String? = call.argument("image")

                val activity: Activity = registrar.activity()
                Log.d(TAG, "$activity")

                val intent = Intent()
                intent.action = Intent.ACTION_SEND
                intent.putExtra(Intent.EXTRA_TEXT, content)

                if (image != null) {
                    val file = File(registrar.activeContext().cacheDir, image)
                    val imageFileUri = FileProvider.getUriForFile(
                        registrar.activeContext(),
                        "${activity.packageName}.com.shekarmudaliyar.social_share",
                        file,
                    )
                    intent.type = "image/*"
                    intent.putExtra(Intent.EXTRA_STREAM, imageFileUri)
                } else {
                    intent.type = "text/plain"
                }

                val chooserIntent: Intent = Intent.createChooser(intent, null)

                try {
                    activity.startActivity(chooserIntent)
                } catch (e: Exception) {
                    result.success("error")
                    Log.e(TAG, "error", e)
                    return
                }
                result.success("success")

            }
            "copyToClipboard" -> {
                val content: String? = call.argument("content")

                val clipboard =
                    registrar.context().getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                val clip = ClipData.newPlainText("", content)
                clipboard.setPrimaryClip(clip)
                result.success(true)
            }
            "shareWhatsapp" -> {
                val content: String? = call.argument("content")

                val intent = Intent(Intent.ACTION_SEND)
                intent.type = "text/plain"
                intent.setPackage("com.whatsapp")
                intent.putExtra(Intent.EXTRA_TEXT, content)

                val activity: Activity = registrar.activity()
                Log.d(TAG, "$activity")

                try {
                    activity.startActivity(intent)
                } catch (e: Exception) {
                    result.success("error")
                    Log.e(TAG, "error", e)
                    return
                }
                result.success("success")
            }
            "shareSms" -> {
                val content: String? = call.argument("message")

                val intent = Intent(Intent.ACTION_SENDTO)
                intent.addCategory(Intent.CATEGORY_DEFAULT)
                intent.type = "vnd.android-dir/mms-sms"
                intent.data = Uri.parse("sms:")
                intent.putExtra("sms_body", content)

                val activity: Activity = registrar.activity()
                Log.d(TAG, "$activity")

                try {
                    activity.startActivity(intent)
                } catch (e: Exception) {
                    result.success("error")
                    Log.e(TAG, "error", e)
                    return
                }
                result.success("success")
            }
            "shareTwitter" -> {
                val text: String? = call.argument("captionText")
                val url: String? = call.argument("url")
                val trailingText: String? = call.argument("trailingText")
                val urlScheme = "http://www.twitter.com/intent/tweet?text=$text$url$trailingText"
                Log.d("log", urlScheme)
                val intent = Intent(Intent.ACTION_VIEW)
                intent.data = Uri.parse(urlScheme)

                val activity: Activity = registrar.activity()
                Log.d(TAG, "$activity")

                try {
                    activity.startActivity(intent)
                } catch (e: Exception) {
                    result.success("error")
                    Log.e(TAG, "error", e)
                    return
                }
                result.success("success")
            }
            "shareTelegram" -> {
                val content: String? = call.argument("content")
                val intent = Intent(Intent.ACTION_SEND)
                intent.type = "text/plain"
                intent.setPackage("org.telegram.messenger")
                intent.putExtra(Intent.EXTRA_TEXT, content)

                val activity: Activity = registrar.activity()
                Log.d(TAG, "$activity")

                try {
                    activity.startActivity(intent)
                } catch (e: Exception) {
                    result.success("error")
                    Log.e(TAG, "error", e)
                    return
                }
                result.success("success")
            }
            "checkInstalledApps" -> {
                //check if the apps exists
                //creating a mutable map of apps
                val apps: MutableMap<String, Boolean> = mutableMapOf()
                //assigning package manager
                val pm: PackageManager = registrar.context().packageManager
                //get a list of installed apps.
                val packages = pm.getInstalledApplications(PackageManager.GET_META_DATA)
                //intent to check sms app exists
                val intent = Intent(Intent.ACTION_SENDTO).addCategory(Intent.CATEGORY_DEFAULT)
                intent.type = "vnd.android-dir/mms-sms"
                intent.data = Uri.parse("sms:")
                val resolvedActivities: List<ResolveInfo> = pm.queryIntentActivities(intent, 0)
                //if sms app exists
                apps["sms"] = resolvedActivities.isNotEmpty()
                //if other app exists
                apps["instagram"] =
                    packages.any { it.packageName.toString().contentEquals("com.instagram.android") }
                apps["facebook"] =
                    packages.any { it.packageName.toString().contentEquals("com.facebook.katana") }
                apps["twitter"] =
                    packages.any { it.packageName.toString().contentEquals("com.twitter.android") }
                apps["whatsapp"] =
                    packages.any { it.packageName.toString().contentEquals("com.whatsapp") }
                apps["telegram"] =
                    packages.any { it.packageName.toString().contentEquals("org.telegram.messenger") }

                result.success(apps)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private companion object {
        private val TAG = SocialSharePlugin::class.java.name

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "social_share")
            channel.setMethodCallHandler(SocialSharePlugin(registrar))
        }
    }
}
