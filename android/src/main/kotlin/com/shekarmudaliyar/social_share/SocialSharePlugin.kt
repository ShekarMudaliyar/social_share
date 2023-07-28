package com.shekarmudaliyar.social_share

import android.app.Activity
import android.content.*
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.File
import java.net.URLEncoder
import android.content.ClipData

import android.provider.MediaStore

import android.content.ContentResolver

import android.content.ContentValues

import android.content.Context




class SocialSharePlugin:FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var activeContext: Context? = null
    private var context: Context? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "social_share")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        activeContext = if (activity != null) activity!!.applicationContext else context!!
        
        


        if (call.method == "shareInstagramStory" || call.method == "shareFacebookStory") {

            val destination : String
            val appName : String
            val intentString : String

            if (call.method == "shareInstagramStory") {
                destination = "com.instagram.sharedSticker"
                appName = "com.instagram.android"
                intentString = "com.instagram.share.ADD_TO_STORY"
            } else {
                destination = "com.facebook.sharedSticker";
                appName = "com.facebook.katana";
                intentString = "com.facebook.stories.ADD_TO_STORY"
            }
            
            val stickerImage: String? = call.argument("stickerImage")
            val backgroundTopColor: String? = call.argument("backgroundTopColor")
            val backgroundBottomColor: String? = call.argument("backgroundBottomColor")
            val attributionURL: String? = call.argument("attributionURL")
            val backgroundImage: String? = call.argument("backgroundImage")
            val backgroundVideo: String? = call.argument("backgroundVideo")

            
            val appId: String? = call.argument("appId")
            val file =  File(activeContext!!.cacheDir,stickerImage)
            val stickerImageFile = FileProvider.getUriForFile(activeContext!!, activeContext!!.applicationContext.packageName + ".com.shekarmudaliyar.social_share", file)
            val intent = Intent(intentString)

            intent.type = "image/*"
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            intent.putExtra("interactive_asset_uri", stickerImageFile)

            if (call.method == "shareFacebookStory") {
                intent.putExtra("com.facebook.platform.extra.APPLICATION_ID", appId)
            }

            if (backgroundImage!=null) {
                //check if background image is also provided
                val backfile =  File(activeContext!!.cacheDir,backgroundImage)
                val backgroundImageFile = FileProvider.getUriForFile(activeContext!!, activeContext!!.applicationContext.packageName + ".com.shekarmudaliyar.social_share", backfile)
                intent.setDataAndType(backgroundImageFile,"image/*")
            }

            if (backgroundVideo!=null) {
                //check if background video is also provided
                val backfile =  File(activeContext!!.cacheDir,backgroundVideo)
                val backgroundVideoFile = FileProvider.getUriForFile(activeContext!!, activeContext!!.applicationContext.packageName + ".com.shekarmudaliyar.social_share", backfile)
                intent.setDataAndType(backgroundVideoFile,"video/*")
            }

            intent.putExtra("source_application", appId)
            intent.putExtra("content_url", attributionURL)
            intent.putExtra("top_background_color", backgroundTopColor)
            intent.putExtra("bottom_background_color", backgroundBottomColor)
            // Instantiate activity and verify it will resolve implicit intent
            activity!!.grantUriPermission(appName, stickerImageFile, Intent.FLAG_GRANT_READ_URI_PERMISSION)
            if (activity!!.packageManager.resolveActivity(intent, 0) != null) {
                activeContext!!.startActivity(intent)
                result.success("success")
            } else {
                result.success("error")
            }
        } else if (call.method == "shareOptions") {
            //native share options
            val content: String? = call.argument("content")
            val image: String? = call.argument("image")
            val intent = Intent()
            intent.action = Intent.ACTION_SEND

            if (image!=null) {
                //check if  image is also provided
                val imagefile =  File(activeContext!!.cacheDir,image)
                val imageFileUri = FileProvider.getUriForFile(activeContext!!, activeContext!!.applicationContext.packageName + ".com.shekarmudaliyar.social_share", imagefile)
                intent.type = "image/*"
                intent.putExtra(Intent.EXTRA_STREAM,imageFileUri)
            } else {
                intent.type = "text/plain";
            }

            intent.putExtra(Intent.EXTRA_TEXT, content)
            
            intent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

            //create chooser intent to launch intent
            //source: "share" package by flutter (https://github.com/flutter/plugins/blob/master/packages/share/)
            val chooserIntent: Intent = Intent.createChooser(intent, "Share Image")
            chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            
            activeContext!!.startActivity(chooserIntent)
            result.success(true)

        } else if (call.method == "copyToClipboard") {


            //copies content onto the clipboard
            val content: String? = call.argument("content")
            val image: String? = call.argument("image")

            val clipboard =context!!.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            if (image != null) {

                val values = ContentValues(2)
                values.put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
                values.put(MediaStore.Images.Media.DATA, image)
                val theContent: ContentResolver = activeContext!!.getContentResolver()
                val imageUri =
                    theContent.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                val clip = ClipData.newUri(theContent, "Image", imageUri)
                clipboard.setPrimaryClip(clip)
                
            } else if (content != null) {
                val clip = ClipData.newPlainText("", content)
                clipboard.setPrimaryClip(clip)
            } else {
                result.success("error")
                return
            }
            result.success("success")
        } 
        else if (call.method == "shareWhatsapp") {
            //shares content on WhatsApp
            val content: String? = call.argument("content")
            val whatsappIntent = Intent(Intent.ACTION_SEND)
            whatsappIntent.type = "text/plain"
            whatsappIntent.setPackage("com.whatsapp")
            whatsappIntent.putExtra(Intent.EXTRA_TEXT, content)
            try {
                activity!!.startActivity(whatsappIntent)
                result.success("success")
            } catch (ex: ActivityNotFoundException) {
                result.success("error")
            }
        } else if (call.method == "shareSms") {
            //shares content on sms
            val content: String? = call.argument("message")
            val intent = Intent(Intent.ACTION_SENDTO)
            intent.addCategory(Intent.CATEGORY_DEFAULT)
            intent.type = "vnd.android-dir/mms-sms"
            intent.data = Uri.parse("sms:" )
            intent.putExtra("sms_body", content)
            try {
                activity!!.startActivity(intent)
                result.success("success")
            } catch (ex: ActivityNotFoundException) {
                result.success("error")
            }
        } else if (call.method == "shareTwitter") {
            //shares content on twitter
            val text: String? = call.argument("captionText")
            val urlScheme = "http://www.twitter.com/intent/tweet?text=${URLEncoder.encode(text, Charsets.UTF_8.name())}"
            Log.d("", urlScheme)

            val intent = Intent(Intent.ACTION_VIEW)
            intent.data = Uri.parse(urlScheme)
            try {
                activity!!.startActivity(intent)
                result.success("success")
            } catch (ex: ActivityNotFoundException) {
                result.success("error")
            }
        }
        else if (call.method == "shareTelegram") {
            //shares content on Telegram
            val content: String? = call.argument("content")
            val telegramIntent = Intent(Intent.ACTION_SEND)
            telegramIntent.type = "text/plain"
            telegramIntent.setPackage("org.telegram.messenger")
            telegramIntent.putExtra(Intent.EXTRA_TEXT, content)
            try {
                activity!!.startActivity(telegramIntent)
                result.success("success")
            } catch (ex: ActivityNotFoundException) {
                result.success("error")
            }
        }
        else if (call.method == "checkInstalledApps") {
            //check if the apps exists
            //creating a mutable map of apps
            var apps:MutableMap<String, Boolean> = mutableMapOf()
            //assigning package manager
            val pm: PackageManager =context!!.packageManager
            //get a list of installed apps.
            val packages = pm.getInstalledApplications(PackageManager.GET_META_DATA)
            //intent to check sms app exists
            val intent = Intent(Intent.ACTION_SENDTO).addCategory(Intent.CATEGORY_DEFAULT)
            intent.type = "vnd.android-dir/mms-sms"
            intent.data = Uri.parse("sms:" )
            val resolvedActivities: List<ResolveInfo>  = pm.queryIntentActivities(intent, 0)
            //if sms app exists
            apps["sms"] = resolvedActivities.isNotEmpty()
            //if other app exists
            apps["instagram"] = packages.any  { it.packageName.toString().contentEquals("com.instagram.android") }
            apps["facebook"] = packages.any  { it.packageName.toString().contentEquals("com.facebook.katana") }
            apps["twitter"] = packages.any  { it.packageName.toString().contentEquals("com.twitter.android") }
            apps["whatsapp"] = packages.any  { it.packageName.toString().contentEquals("com.whatsapp") }
            apps["telegram"] = packages.any  { it.packageName.toString().contentEquals("org.telegram.messenger") }

            result.success(apps)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.getActivity()
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
