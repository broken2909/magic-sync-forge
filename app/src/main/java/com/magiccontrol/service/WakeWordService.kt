package com.magiccontrol.service

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.magiccontrol.recognizer.WakeWordDetector
import com.magiccontrol.tts.TTSManager
import com.magiccontrol.utils.WelcomeManager

class WakeWordService : Service() {

    private lateinit var wakeWordDetector: WakeWordDetector
    private val TAG = "WakeWordService"
    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service de détection de mot d'activation créé")
        
        try {
            wakeWordDetector = WakeWordDetector(applicationContext)
            
            // Configuration du callback Z.ai
            wakeWordDetector.onWakeWordDetected = {
                Log.d(TAG, "Mot d'activation détecté - Lancement reconnaissance complète")
                val message = WelcomeManager.getMagicDetectedMessage()
                TTSManager.speak(applicationContext, message)
                startFullRecognition()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erreur création détecteur", e)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Démarrage du service de détection")
        
        try {
            startWakeWordDetection()
        } catch (e: Exception) {
            Log.e(TAG, "Erreur démarrage service", e)
        }
        
        return START_STICKY
    }

    private fun startWakeWordDetection() {
        try {
            // Vérifier si le système est fonctionnel AVANT de démarrer
            if (wakeWordDetector.isSystemFunctional()) {
                val success = wakeWordDetector.startListening()
                
                if (success) {
                    // Message détection retardé de 4 secondes pour laisser passer le welcome
                    handler.postDelayed({
                        val message = WelcomeManager.getDetectionActiveMessage()
                        TTSManager.speak(applicationContext, message)
                    }, 4000)
                } else {
                    Log.w(TAG, "Détection démarrée mais avec des limitations")
                    // Pas de message "Détection activée" si démarrage partiel
                }
            } else {
                Log.e(TAG, "Système vocal non fonctionnel - Micro peut-être bloqué")
                // Pas de message "Détection activée" si système défaillant
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erreur lors du démarrage de la détection", e)
            // Pas de message "Détection activée" en cas d'erreur
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
