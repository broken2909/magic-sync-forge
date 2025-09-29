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
