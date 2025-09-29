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

        setupToolbar()
        setupButtons()
        startWakeWordService()
        showWelcomeIfNeeded()
    }

    private fun setupToolbar() {
        setSupportActionBar(binding.toolbar)
    }

    private fun setupButtons() {
        binding.voiceButton.setOnClickListener {
            // TODO: Implement direct voice command
        }

        binding.settingsButton.setOnClickListener {
            // TODO: Open settings activity - Temporairement désactivé pour éviter les crashes
            TTSManager.speak(this, "Paramètres temporairement indisponibles")
        }
    }

    private fun startWakeWordService() {
        val intent = Intent(this, WakeWordService::class.java)
        startService(intent)
    }

    private fun showWelcomeIfNeeded() {
        if (WelcomeManager.shouldShowWelcome(this)) {
            // CORRECTION: getWelcomeMessage() sans paramètre
            val welcomeMessage = WelcomeManager.getWelcomeMessage()
            TTSManager.speak(this, welcomeMessage)
            Toast.makeText(this, welcomeMessage, Toast.LENGTH_LONG).show()
            WelcomeManager.markWelcomeShown(this)
        } else {
            // Message normal pour les ouvertures suivantes
            TTSManager.speak(this, "MagicControl activé")
        }
    }

    private fun playWelcomeSound() {
        // TODO: Implémenter le son de bienvenue si nécessaire
    }

    override fun onDestroy() {
        super.onDestroy()
        // Cleanup if needed
    }
}
