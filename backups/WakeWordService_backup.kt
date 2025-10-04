package com.magiccontrol.service

import android.app.*
import android.content.Intent
import android.content.pm.PackageManager
import android.os.*
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.magiccontrol.MainActivity
import com.magiccontrol.recognizer.WakeWordDetector
import com.magiccontrol.tts.TTSManager
import com.magiccontrol.utils.PreferencesManager

class WakeWordService : Service() {

    private var wakeWordDetector: WakeWordDetector? = null
    private val TAG = "WakeWordService"
    private val NOTIFICATION_ID = 1001
    private val CHANNEL_ID = "MAGIC_CONTROL_CHANNEL"
    private var serviceStarted = false

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service créé")
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Démarrage service")
        
        if (serviceStarted) {
            return START_STICKY
        }

        try {
            startForegroundService()
            initializeAudioDetector()
            serviceStarted = true
            Log.d(TAG, "Service activé")
        } catch (e: Exception) {
            Log.e(TAG, "Erreur démarrage", e)
            return START_NOT_STICKY
        }

        return START_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Magic Control",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }

    private fun startForegroundService() {
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Magic Control Actif")
            .setContentText("Micro prêt")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setOngoing(true)
            .build()

        startForeground(NOTIFICATION_ID, notification)
    }

    private fun initializeAudioDetector() {
        try {
            wakeWordDetector = WakeWordDetector(applicationContext)
            wakeWordDetector?.onWakeWordDetected = {
                onWakeWordDetected()
            }
            Handler(Looper.getMainLooper()).postDelayed({
                startListening()
            }, 1000L)
        } catch (e: Exception) {
            Log.e(TAG, "Erreur détecteur", e)
        }
    }

    private fun startListening() {
        try {
            val success = wakeWordDetector?.startListening() ?: false
            if (success) {
                Log.d(TAG, "Écoute activée")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erreur écoute", e)
        }
    }

    private fun onWakeWordDetected() {
        Log.d(TAG, "Mot-clé détecté")
        TTSManager.speak(applicationContext, "Oui?")
        
        Handler(Looper.getMainLooper()).postDelayed({
            val intent = Intent(this, FullRecognitionService::class.java)
            startService(intent)
        }, 500L)
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Service arrêté")
        wakeWordDetector?.stopListening()
        serviceStarted = false
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
