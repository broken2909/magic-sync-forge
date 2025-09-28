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
    private var downloadJob: Job? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val modelUrl = intent?.getStringExtra("model_url")
        val modelName = intent?.getStringExtra("model_name")
        
        if (modelUrl != null && modelName != null) {
            downloadJob = downloadScope.launch {
                downloadModel(modelUrl, modelName)
            }
        } else {
            Log.e(TAG, "URL ou nom du modèle manquant")
            stopSelf()
        }
        
        return START_NOT_STICKY
    }

    private suspend fun downloadModel(modelUrl: String, modelName: String) {
        try {
            Log.d(TAG, "Début téléchargement: $modelName depuis $modelUrl")
            
            val url = URL(modelUrl)
            val connection = url.openConnection() as HttpURLConnection
            connection.connect()
            
            val inputStream = connection.inputStream
            val modelsDir = File(filesDir, "models")
            if (!modelsDir.exists()) {
                modelsDir.mkdirs()
            }
            
            val outputFile = File(modelsDir, "$modelName.zip")
            val outputStream = FileOutputStream(outputFile)
            
            val buffer = ByteArray(1024)
            var totalBytesRead = 0L
            var bytesRead: Int
            
            while (inputStream.read(buffer).also { bytesRead = it } != -1) {
                outputStream.write(buffer, 0, bytesRead)
                totalBytesRead += bytesRead
                
                // Log progression
                if (totalBytesRead % (1024 * 1024) == 0L) { // Tous les 1MB
                    Log.d(TAG, "Téléchargement $modelName: ${totalBytesRead / (1024 * 1024)}MB")
                }
            }
            
            outputStream.close()
            inputStream.close()
            connection.disconnect()
            
            Log.d(TAG, "Téléchargement terminé: $modelName - ${totalBytesRead} bytes")
            
            // TODO: Extraire le ZIP et mettre à jour ModelManager
            
        } catch (e: Exception) {
            Log.e(TAG, "Erreur téléchargement modèle $modelName", e)
        } finally {
            stopSelf()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        downloadJob?.cancel()
        Log.d(TAG, "Service de téléchargement arrêté")
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
