package com.magiccontrol

import android.app.Application
import com.magiccontrol.tts.TTSManager

class MagicControlApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Initialiser le TTS au démarrage de l'application
        TTSManager.initialize(this)
    }
}
