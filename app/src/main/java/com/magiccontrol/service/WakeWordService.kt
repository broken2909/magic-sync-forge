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
