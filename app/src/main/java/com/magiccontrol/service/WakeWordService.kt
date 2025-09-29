package com.magiccontrol.service

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log
import com.magiccontrol.recognizer.WakeWordDetector
import com.magiccontrol.tts.TTSManager

class WakeWordService : Service() {

    private lateinit var wakeWordDetector: WakeWordDetector
    private val TAG = "WakeWordService"

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service de détection de mot d'activation créé")
        
        try {
            wakeWordDetector = WakeWordDetector(applicationContext)
            
            // Configuration du callback Z.ai
            wakeWordDetector.onWakeWordDetected = {
                Log.d(TAG, "Mot d'activation détecté - Lancement reconnaissance complète")
                TTSManager.speak(applicationContext, "Mot magic détecté")
                startFullRecognition()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erreur création détecteur", e)
            TTSManager.speak(applicationContext, "Erreur service vocal")
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Démarrage du service de détection")
        
        try {
            startWakeWordDetection()
        } catch (e: Exception) {
            Log.e(TAG, "Erreur démarrage service", e)
            TTSManager.speak(applicationContext, "Erreur démarrage")
        }
        
        return START_STICKY
    }

    private fun startWakeWordDetection() {
        try {
            wakeWordDetector.startListening()
            TTSManager.speak(applicationContext, "Détection activée")
        } catch (e: Exception) {
            Log.e(TAG, "Erreur lors du démarrage de la détection", e)
            TTSManager.speak(applicationContext, "Microphone non disponible")
        }
    }

    private fun startFullRecognition() {
        try {
            val intent = Intent(this, FullRecognitionService::class.java)
            startService(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Erreur lancement reconnaissance", e)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Arrêt du service de détection")
        
        try {
            wakeWordDetector.stopListening()
        } catch (e: Exception) {
            Log.e(TAG, "Erreur arrêt détection", e)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
