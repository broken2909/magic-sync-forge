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
        
        setupToolbar()
        setupButtons()
        showWelcomeIfNeeded()
        
        // Services sans permission complexe (pour test)
        android.os.Handler().postDelayed({
            startWakeWordService()
        }, 3000)
    }

    private fun setupToolbar() {
        setSupportActionBar(binding.toolbar)
    }

    private fun setupButtons() {
        binding.voiceButton.setOnClickListener {
            // TODO: Implement direct voice command
        }

        binding.settingsButton.setOnClickListener {
            TTSManager.speak(this, "Paramètres temporairement indisponibles")
        }
    }

    private fun showWelcomeIfNeeded() {
        if (WelcomeManager.shouldShowWelcome(this)) {
            val welcomeMessage = WelcomeManager.getWelcomeMessage()
            TTSManager.speak(this, welcomeMessage)
            Toast.makeText(this, welcomeMessage, Toast.LENGTH_LONG).show()
            WelcomeManager.markWelcomeShown(this)
        } else {
            TTSManager.speak(this, "MagicControl activé")
        }
    }

    private fun startWakeWordService() {
        val intent = Intent(this, WakeWordService::class.java)
        startService(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
    }
}
