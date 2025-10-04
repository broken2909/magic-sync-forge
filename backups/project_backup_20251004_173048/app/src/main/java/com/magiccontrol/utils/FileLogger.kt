package com.magiccontrol.utils

import android.content.Context
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object FileLogger {
    private const val TAG = "FileLogger"
    
    fun logToFile(context: Context, message: String) {
        try {
            val timestamp = SimpleDateFormat("HH:mm:ss", Locale.getDefault()).format(Date())
            val logMessage = "[$timestamp] $message\n"
            
            // Log système
            Log.d(TAG, message)
            
            // Log fichier interne
            val file = File(context.filesDir, "app_debug.log")
            FileOutputStream(file, true).use { fos ->
                fos.write(logMessage.toByteArray())
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erreur écriture log fichier", e)
        }
    }
    
    fun getLogFile(context: Context): File {
        return File(context.filesDir, "app_debug.log")
    }
}
