package com.magiccontrol.service

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import java.io.File
import java.io.FileOutputStream
import java.net.HttpURLConnection
import java.net.URL

class ModelDownloadService : Service() {

    private val TAG = "ModelDownloadService"
    private val downloadScope = CoroutineScope(Dispatchers.IO + Job())

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service de téléchargement des modèles créé")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val modelUrl = intent?.getStringExtra("model_url")
        val modelName = intent?.getStringExtra("model_name")
        
        if (modelUrl != null && modelName != null) {
            downloadModel(modelUrl, modelName)
        }
        
        return START_NOT_STICKY
    }

    private fun downloadModel(url: String, modelName: String) {
        downloadScope.launch {
            try {
                Log.d(TAG, "Début du téléchargement du modèle: $modelName")
                
                val connection = URL(url).openConnection() as HttpURLConnection
                connection.connect()
                
                val modelsDir = File(filesDir, "models")
                if (!modelsDir.exists()) {
                    modelsDir.mkdirs()
                }
                
                val outputFile = File(modelsDir, modelName)
                val outputStream = FileOutputStream(outputFile)
                
                connection.inputStream.use { input ->
                    outputStream.use { output ->
                        input.copyTo(output)
                    }
                }
                
                Log.d(TAG, "Modèle téléchargé avec succès: $modelName")
                
            } catch (e: Exception) {
                Log.e(TAG, "Erreur lors du téléchargement du modèle", e)
            } finally {
                stopSelf()
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}