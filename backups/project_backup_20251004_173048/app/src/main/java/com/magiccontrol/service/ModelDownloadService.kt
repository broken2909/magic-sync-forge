package com.magiccontrol.service

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream

class ModelDownloadService : Service() {
    private val TAG = "ModelDownloadService"

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Verification modeles Vosk")
        
        Thread {
            try {
                val modelCode = "fr-small"
                val assetPath = "models/vosk-model-small-fr"
                
                // 🔥 VÉRIFICATION si extraction nécessaire
                val isExtracted = isModelExtracted(modelCode)
                Log.d(TAG, "Modeles deja extraits: $isExtracted")
                
                var wasExtractionNeeded = false
                var success = true
                
                if (!isExtracted) {
                    Log.d(TAG, "Extraction necessaire")
                    wasExtractionNeeded = true
                    success = extractModelRecursive(modelCode, assetPath)
                    Log.d(TAG, "Resultat extraction: $success")
                } else {
                    Log.d(TAG, "Modeles deja presents - aucune action")
                }
                
                // 🔥 BROADCAST CONDITIONNEL
                if (wasExtractionNeeded) {
                    val message = if (success) 
                        "Configuration terminee - Application prete" 
                    else 
                        "Erreur extraction"
                    
                    val resultIntent = Intent("EXTRACTION_COMPLETE")
                    resultIntent.putExtra("success", success)
                    resultIntent.putExtra("message", message)
                    LocalBroadcastManager.getInstance(this).sendBroadcast(resultIntent)
                    Log.d(TAG, "Broadcast envoye: extraction necessaire")
                } else {
                    Log.d(TAG, "Aucun broadcast: modeles deja presents")
                }
                
            } catch (e: Exception) {
                Log.e(TAG, "Erreur verification", e)
            } finally {
                stopSelf()
            }
        }.start()

        return START_NOT_STICKY
    }

    private fun isModelExtracted(modelCode: String): Boolean {
        val modelDir = File(filesDir, "models/$modelCode")
        val exists = modelDir.exists()
        val hasFiles = modelDir.listFiles()?.isNotEmpty() ?: false
        Log.d(TAG, "Verification $modelCode: exists=$exists, hasFiles=$hasFiles")
        return exists && hasFiles
    }

    private fun extractModelRecursive(modelCode: String, assetPath: String): Boolean {
        Log.d(TAG, "Extraction recursive: $assetPath")
        
        val targetDir = File(filesDir, "models/$modelCode")
        targetDir.mkdirs()
        
        return extractAssetsRecursive(assetPath, targetDir, assetPath)
    }

    private fun extractAssetsRecursive(currentAssetPath: String, currentTargetDir: File, baseAssetPath: String): Boolean {
        try {
            val items = assets.list(currentAssetPath)
            if (items == null || items.isEmpty()) return false
            
            var successCount = 0
            for (item in items) {
                val fullAssetPath = if (currentAssetPath.isEmpty()) item else "$currentAssetPath/$item"
                
                try {
                    val inputStream: InputStream = assets.open(fullAssetPath)
                    val outputFile = File(currentTargetDir, item)
                    val outputStream = FileOutputStream(outputFile)
                    inputStream.copyTo(outputStream)
                    inputStream.close()
                    outputStream.close()
                    successCount++
                } catch (e: Exception) {
                    val subTargetDir = File(currentTargetDir, item)
                    subTargetDir.mkdirs()
                    if (extractAssetsRecursive(fullAssetPath, subTargetDir, baseAssetPath)) {
                        successCount++
                    }
                }
            }
            return successCount == items.size
        } catch (e: Exception) {
            Log.e(TAG, "Erreur extraction $currentAssetPath", e)
            return false
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
