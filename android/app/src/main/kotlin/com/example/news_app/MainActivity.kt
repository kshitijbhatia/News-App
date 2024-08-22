package com.example.news_app

import android.app.NotificationManager
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat.getSystemService
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


class MainActivity: FlutterActivity() {
    private val _channel = "com.example.news_app"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, _channel).apply {
            setMethodCallHandler { call, result ->
                if(call.method == "showCustomNotification"){
                    var args = call.arguments as Map<String, String>
                    val title = args.get("title") as String
                    val body = args.get("body") as String
                    val channelID = args.get("channel_id") as String
                    showNotification(title, body, channelID)
                    result.success("Received on Android Side")
                }else{
                    result.notImplemented()
                }
            }
        }
    }

    private fun showNotification(title: String, body: String, channelId: String){

        val notificationLayout = RemoteViews(packageName, R.layout.notification_small)
        val notificationLayoutExpanded = RemoteViews(packageName, R.layout.notification_large)

        // Set the title and body in the custom notification layout
        notificationLayout.setTextViewText(R.id.notification_title, title)
        notificationLayout.setTextViewText(R.id.notification_body, body)
        notificationLayoutExpanded.setTextViewText(R.id.notification_title, title)
        notificationLayoutExpanded.setTextViewText(R.id.notification_body, body)

        var builder = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(R.drawable.ic_stat_warning)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCustomContentView(notificationLayout)
            .setCustomBigContentView(notificationLayoutExpanded)

        val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(1, builder.build())
    }
}