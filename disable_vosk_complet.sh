#!/bin/bash
echo "🔧 DÉSACTIVATION COMPLÈTE VOSK TEMPORAIRE"

# Remplacer FullRecognitionService par version sans Vosk
cat > app/src/main/java/com/magiccontrol/service/FullRecognitionService.kt << 'FILE1'
package com.magiccontrol.service

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log
import com.magiccontrol.tts.TTSManager

class FullRecognitionService : Service() {

    private val TAG = "FullRecognitionService"

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service créé - Mode simulation")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Service démarré - Vosk désactivé temporairement")
        TTSManager.speak(applicationContext, "Reconnaissance vocale désactivée pour Phase 1")
        stopSelf()
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Service arrêté")
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
FILE1

# Désactiver aussi WakeWordService s'il utilise Vosk
cat > app/src/main/java/com/magiccontrol/service/WakeWordService.kt << 'FILE2'
package com.magiccontrol.service

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log

class WakeWordService : Service() {

    private val TAG = "WakeWordService"

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service WakeWord créé - Mode passif")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "WakeWord en mode passif - Phase 1")
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Service WakeWord arrêté")
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
FILE2

echo "✅ VOSK COMPLÈTEMENT DÉSACTIVÉ!"
echo "📊 État Phase 1:"
echo "   - ✅ MainActivity: Toast + Welcome + Permission"
echo "   - ✅ FullRecognitionService: Mode simulation"
echo "   - ✅ WakeWordService: Mode passif" 
echo "   - ❌ Vosk: Désactivé temporairement"
echo ""
echo "🚀 Build devrait maintenant RÉUSSIR!"
