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
    private var isServiceFunctional = false

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service de détection de mot d'activation créé")
        
        try {
            wakeWordDetector = WakeWordDetector(applicationContext)
            
            // Configuration du callback
            wakeWordDetector.onWakeWordDetected = {
                Log.d(TAG, "Mot d'activation détecté")
                try {
                    TTSManager.speak(applicationContext, "Magic")
                    startFullRecognition()
                } catch (e: Exception) {
                    Log.e(TAG, "Erreur traitement mot d'activation", e)
                }
            }
            isServiceFunctional = true
            Log.d(TAG, "Détecteur initialisé avec succès")
        } catch (e: Exception) {
            Log.e(TAG, "ERREUR: Impossible de créer le détecteur", e)
            isServiceFunctional = false
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Démarrage du service de détection")
        
        if (!isServiceFunctional) {
            Log.w(TAG, "Service non fonctionnel - Mode passif")
            return START_STICKY
        }
        
        try {
            val success = wakeWordDetector.startListening()
            if (success) {
                Log.d(TAG, "Détection démarrée avec succès")
            } else {
                Log.w(TAG, "Détection non démarrée - Permission manquante")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erreur démarrage détection", e)
        }
        
        return START_STICKY
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
            if (::wakeWordDetector.isInitialized) {
                wakeWordDetector.stopListening()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erreur lors de l'arrêt du détecteur", e)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
