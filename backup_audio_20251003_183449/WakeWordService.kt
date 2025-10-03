package com.magiccontrol.service

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.magiccontrol.recognizer.WakeWordDetector
import com.magiccontrol.tts.TTSManager
import com.magiccontrol.R

class WakeWordService : Service() {

    private lateinit var wakeWordDetector: WakeWordDetector
    private val TAG = "WakeWordService"

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service de détection de mot d'activation créé")
        wakeWordDetector = WakeWordDetector(applicationContext)
        
        wakeWordDetector.onWakeWordDetected = {
            Log.d(TAG, "Mot d'activation détecté - Lancement reconnaissance complète")
            startFullRecognition()
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Démarrage du service de détection")
        
        // DÉLAI de 3 secondes pour que le message bienvenue se termine
        Handler(Looper.getMainLooper()).postDelayed({
            // MESSAGE "Dites Magic" APRÈS le message bienvenue
            TTSManager.speak(applicationContext, applicationContext.getString(R.string.activation_prompt))
            startWakeWordDetection()
        }, 3000L)
        
        return START_STICKY
    }

    private fun startWakeWordDetection() {
        try {
            wakeWordDetector.startListening()
        } catch (e: Exception) {
            Log.e(TAG, "Erreur démarrage détection", e)
        }
    }

    private fun startFullRecognition() {
        val intent = Intent(this, FullRecognitionService::class.java)
        startService(intent)
        Log.d(TAG, "FullRecognitionService démarré")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Arrêt du service de détection")
        wakeWordDetector.stopListening()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
