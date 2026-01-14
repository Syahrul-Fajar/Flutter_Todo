package com.farsy.todo

import android.app.Activity
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL_NAME = "com.farsy.todo/settings"
    private val RINGTONE_PICKER_REQUEST_CODE = 999
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME).setMethodCallHandler { call, result ->
            if (call.method == "pickRingtone") {
                pendingResult = result
                val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER)
                intent.putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_ALARM)
                intent.putExtra(RingtoneManager.EXTRA_RINGTONE_TITLE, "Pilih Nada Alarm")
                intent.putExtra(RingtoneManager.EXTRA_RINGTONE_EXISTING_URI, null as Uri?)
                startActivityForResult(intent, RINGTONE_PICKER_REQUEST_CODE)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == RINGTONE_PICKER_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                val uri: Uri? = data.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
                if (uri != null) {
                    try {
                        // Cleanup old files
                        filesDir.listFiles()?.forEach { 
                            if (it.name.startsWith("custom_alarm_sound_")) {
                                it.delete()
                            }
                        }

                        val inputStream = contentResolver.openInputStream(uri)
                        // Create unique file
                        val fileName = "custom_alarm_sound_${System.currentTimeMillis()}.mp3"
                        val file = java.io.File(filesDir, fileName)
                        val outputStream = java.io.FileOutputStream(file)
                        inputStream?.copyTo(outputStream)
                        inputStream?.close()
                        outputStream.close()
                        
                        pendingResult?.success(file.absolutePath)
                    } catch (e: Exception) {
                        e.printStackTrace()
                        pendingResult?.success(null)
                    }
                } else {
                    pendingResult?.success(null)
                }
            } else {
                pendingResult?.success(null)
            }
            pendingResult = null
        }
    }
}
