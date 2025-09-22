package com.magiccontrol.service

import android.app.Service
import android.content.Intent
import android.os.IBinder

class WakeWordService : Service() {
    
    private val wakeWordDetector = com.magiccontrol.recognizer.WakeWordDetector(this)
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        wakeWordDetector.startListening()
        return START_STICKY
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
    
    override fun onDestroy() {
        wakeWordDetector.stopListening()
        super.onDestroy()
    }
}
