package com.example.intentdummy

import android.app.Activity
import android.app.PendingIntent.getActivity
import android.content.Intent
import android.os.Bundle
import android.widget.Button
import androidx.appcompat.app.AppCompatActivity
//import sun.jvm.hotspot.utilities.IntArray


class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        val button: Button = findViewById(R.id.button)
        button.setOnClickListener{
            val intent = Intent("com.instagram.share.ADD_TO_STORY")

            intent.putExtra("top_background_color", "#33FF33")
            intent.putExtra("bottom_background_color", "#FF00FF")

// Instantiate activity and verify it will resolve implicit intent
            // Instantiate activity and verify it will resolve implicit intent
            val activity: Activity = this
//            activity.grantUriPermission(
//                "com.instagram.android", stickerAssetUri, Intent.FLAG_GRANT_READ_URI_PERMISSION
//            )
            if (activity.packageManager.resolveActivity(intent, 0) != null) {
                activity.startActivityForResult(intent, 0)
            }
        }
    }
}
