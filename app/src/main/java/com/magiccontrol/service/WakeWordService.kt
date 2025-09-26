package com.magiccontrol.service

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log
import com.magiccontrol.recognizer.WakeWordDetector

class WakeWordService : Service() {

    private lateinit var wakeWordDetector: WakeWordDetector
    private val TAG = "WakeWordService"

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service de détection de mot d'activation créé")
        wakeWordDetector = WakeWordDetector(applicationContext)
       
        // Configuration du callback
        wakeWordDetector.onWakeWordDetected = {
            Log.d(TAG, "Mot d'activation détecté - Lancement reconnaissance complète")
            startFullRecognition()
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Démarrage du service de détection")
        startWakeWordDetection()
        return START_STICKY
    }

    private fun startWakeWordDetection() {
        try {
            wakeWordDetector.startListening()
        } catch (e: Exception) {
            Log.e(TAG, "Erreur lors du démarrage de la détection", e)
        }
    }

    private fun startFullRecognition() {
        val intent = Intent(this, FullRecognitionService::class.java)
        startService(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Arrêt du service de détection")
        wakeWordDetector.stopListening()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}