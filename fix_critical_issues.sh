#!/bin/bash
echo "🔧 CORRECTION CRITIQUES SYSTÈME VOCAL"

# Créer la version corrigée de WakeWordService
cat > app/src/main/java/com/magiccontrol/service/WakeWordService.kt << 'FIX'
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
        wakeWordDetector = WakeWordDetector(applicationContext)
        
        // CORRECTION PRIORITÉ 2: Configuration du callback
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
            // CORRECTION PRIORITÉ 1: Message guidance utilisateur
            TTSManager.speak(applicationContext, "Dites le mot clé pour commencer")
            
            wakeWordDetector.startListening()
        } catch (e: Exception) {
            Log.e(TAG, "Erreur lors du démarrage de la détection", e)
        }
    }

    // CORRECTION PRIORITÉ 2: Activation reconnaissance complète
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
FIX

echo ""
echo "✅ CORRECTIONS APPLIQUÉES:"
echo "📊 PRIORITÉ 1: Message TTS guidance ajouté"
echo "📊 PRIORITÉ 2: Callback FullRecognitionService activé"
echo ""
echo "🔍 VÉRIFICATION APPLIQUÉE:"
grep -n "TTSManager.speak\|FullRecognitionService" app/src/main/java/com/magiccontrol/service/WakeWordService.kt
