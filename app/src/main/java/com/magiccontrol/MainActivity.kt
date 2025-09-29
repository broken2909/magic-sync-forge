package com.magiccontrol

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.magiccontrol.databinding.ActivityMainBinding
import com.magiccontrol.service.WakeWordService
import com.magiccontrol.utils.WelcomeManager
import com.magiccontrol.tts.TTSManager

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        TTSManager.initialize(this)
        
        Toast.makeText(this, "Avec services", Toast.LENGTH_LONG).show()
        
        // Welcome avec TTS
        if (WelcomeManager.shouldShowWelcome(this)) {
            val welcomeMessage = WelcomeManager.getWelcomeMessage()
            TTSManager.speak(this, welcomeMessage)
            Toast.makeText(this, welcomeMessage, Toast.LENGTH_LONG).show()
            WelcomeManager.markWelcomeShown(this)
        }
        
        // TEST: Services seulement
        startWakeWordService()
    }

    private fun startWakeWordService() {
        val intent = Intent(this, WakeWordService::class.java)
        startService(intent)
    }
}
