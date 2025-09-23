package com.magiccontrol.service

import android.app.Service
import android.content.Intent
import android.os.IBinder

class FullRecognitionService : Service() {

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Service de reconnaissance vocale complète
        // À implémenter: reconnaissance vocale réelle
        stopSelf()
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
