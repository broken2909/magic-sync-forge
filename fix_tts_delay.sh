#!/bin/bash
echo "🔧 CORRECTION DÉLAI TTS - Écoute immédiate"

cd /data/data/com.termux/files/home/magic-sync-forge/

# Création version corrigée de WakeWordService
cat > app/src/main/java/com/magiccontrol/service/WakeWordService.kt << 'FILE'
package com.magiccontrol.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import com.magiccontrol.recognizer.WakeWordDetector
import com.magiccontrol.tts.TTSManager
import com.magiccontrol.R

class WakeWordService : Service() {
    private lateinit var wakeWordDetector: WakeWordDetector
    private val TAG = "WakeWordService"
    private val CHANNEL_ID = "WakeWordServiceChannel"

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service de détection créé")
        createNotificationChannel()
        wakeWordDetector = WakeWordDetector(applicationContext)

        wakeWordDetector.onWakeWordDetected = {
            Log.d(TAG, "Mot d activation détecté")
            startFullRecognition()
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Démarrage service détection")

        val notification = createNotification()
        startForeground(1, notification)

        // ✅ CORRECTION : Démarrer l'écoute IMMÉDIATEMENT
        startWakeWordDetection()

        // ✅ TTS après 3 secondes SANS bloquer l'écoute
        Handler(Looper.getMainLooper()).postDelayed({
            TTSManager.speak(applicationContext, applicationContext.getString(R.string.activation_prompt))
        }, 3000L)

        return START_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Service Détection Vocale",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("MagicControl")
            .setContentText("Écoute activation...")
            .setSmallIcon(android.R.drawable.ic_media_play)
            .build()
    }

    private fun startWakeWordDetection() {
        try {
            wakeWordDetector.startListening()
            Log.d(TAG, "Détection démarrée")
        } catch (e: Exception) {
            Log.e(TAG, "Erreur démarrage détection", e)
        }
    }

    private fun startFullRecognition() {
        val intent = Intent(this, FullRecognitionService::class.java)
        startService(intent)
        Log.d(TAG, "Reconnaissance démarrée")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Arrêt service détection")
        wakeWordDetector.stopListening()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
FILE

echo "✅ Correction appliquée : Écoute immédiate + TTS après 3s"
echo "🚀 PUSH: git add . && git commit -m 'FIX: Écoute immédiate sans attente TTS' && git push"
