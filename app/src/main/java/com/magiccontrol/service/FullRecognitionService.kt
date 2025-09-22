package com.magiccontrol.service

import android.app.Service
import android.content.Intent
import android.os.IBinder
import com.magiccontrol.command.CommandProcessor
import com.magiccontrol.tts.TTSManager

class FullRecognitionService : Service() {
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Simuler une commande vocale détectée
        TTSManager.speak("Commande vocale détectée")
        
        // Traiter la commande (exemple)
        CommandProcessor.execute(this, "volume augmenter")
        
        stopSelf()
        return START_NOT_STICKY
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
}
