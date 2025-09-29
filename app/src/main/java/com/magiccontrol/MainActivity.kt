package com.magiccontrol

import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.magiccontrol.databinding.ActivityMainBinding
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
        
        Toast.makeText(this, "Services désactivés - Stable", Toast.LENGTH_LONG).show()
    }

    private fun setupToolbar() {
        setSupportActionBar(binding.toolbar)
    }

    private fun setupButtons() {
        binding.voiceButton.setOnClickListener {
            TTSManager.speak(this, "Commande vocale")
        }

        binding.settingsButton.setOnClickListener {
            TTSManager.speak(this, "Paramètres")
        }
    }

    private fun showWelcomeIfNeeded() {
        if (WelcomeManager.shouldShowWelcome(this)) {
            val welcomeMessage = WelcomeManager.getWelcomeMessage()
            TTSManager.speak(this, welcomeMessage)
            Toast.makeText(this, welcomeMessage, Toast.LENGTH_LONG).show()
            WelcomeManager.markWelcomeShown(this)
        } else {
            TTSManager.speak(this, "MagicControl prêt")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
    }
}
