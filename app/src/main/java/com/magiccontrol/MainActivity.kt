package com.magiccontrol

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.magiccontrol.service.WakeWordService
import com.magiccontrol.tts.TTSManager

class MainActivity : AppCompatActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialiser TTS
        TTSManager.initialize(this)
        
        // Démarrer le service d'écoute
        startService(Intent(this, WakeWordService::class.java))
        
        // Fermer l'activité (l'app tourne en arrière-plan)
        finish()
    }
}
