package com.example.news_app
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File
import android.util.Log
import androidx.annotation.RequiresApi
import java.io.BufferedWriter
import java.io.FileOutputStream
import java.io.OutputStreamWriter
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

class MainActivity: FlutterActivity() {
    private val CHANNEL = "my_news"

    @RequiresApi(Build.VERSION_CODES.N)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "appStartup") {
                val response = appStartup()
                result.success(response)
            } else if(call.method == "api_call"){
                val response = apiCall()
                result.success(response)
            } else {
                result.notImplemented()
            }
        }
    }

    // Method to be called from Flutter
    @RequiresApi(Build.VERSION_CODES.N)
    private fun appStartup(): String {
        val handler = Handler(Looper.getMainLooper())
        val logTask = object : Runnable {
            override fun run() {
                saveLog("Log_Saved_Android")
                handler.postDelayed(this, 50)
            }
        }
        handler.post(logTask)
        return "Hello"
    }

    @RequiresApi(Build.VERSION_CODES.N)
    private fun apiCall(): String {
        // saveLog("Api_Call_Made_Native")
        return "Hello"
    }

    @RequiresApi(Build.VERSION_CODES.N)
    fun saveLog(log: String){
        try{

            val formatter = DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss.SSS")
            val now = LocalDateTime.now()
            val formattedTime = now.format(formatter)

            val filePath = applicationContext.dataDir.absolutePath + "/app_flutter/app_logs.txt"
            Log.d("saveLog", filePath)
            val logFile = File(filePath)

            // Use FileOutputStream and BufferedWriter
            val fileOutputStream = FileOutputStream(logFile, true)
            val bufferedWriter = BufferedWriter(OutputStreamWriter(fileOutputStream))

//            val current = LocalDateTime.now()
//            val formatter = DateTimeFormatter.ISO_LOCAL_DATE_TIME
//            val formattedTime = current.format(formatter)
            bufferedWriter.write("$formattedTime:::>\t\t$log\n")

            bufferedWriter.flush()
            bufferedWriter.close()
            Log.d("Save_Log_Is_Complete", "Log is saved in the native side - $log")

        }catch(error: Error){
            Log.e("errorSaveLog", error.toString())
        }
    }
}


