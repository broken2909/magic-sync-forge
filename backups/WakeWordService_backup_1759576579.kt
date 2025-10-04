package com.magiccontrol.service

import android.app.*
import android.content.Intent
import android.os.*
import android.util.Log
import androidx.core.app.NotificationCompat
import com.magiccontrol.recognizer.WakeWordDetector
import com.magiccontrol.tts.TTSManager

class WakeWordService : Service() {

    private var wakeWordDetector: WakeWordDetector? = null
    private val TAG = "WakeWordService"
    private var serviceStarted = false

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service créé")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Démarrage service")
        
        if (serviceStarted) return START_STICKY

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

    private fun startForegroundService() {
        val notification = NotificationCompat.Builder(this, "MAGIC_CONTROL")
            .setContentTitle("Magic Control Actif")
            .setContentText("Micro prêt")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setOngoing(true)
            .build()
        startForeground(1001, notification)
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
            wakeWordDetector?.startListening()
            Log.d(TAG, "Écoute activée")
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
