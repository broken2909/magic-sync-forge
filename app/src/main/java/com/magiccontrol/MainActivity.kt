package com.magiccontrol

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.magiccontrol.databinding.ActivityMainBinding
import com.magiccontrol.service.WakeWordService
import com.magiccontrol.utils.FirstLaunchWelcome

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setupToolbar()
        setupButtons()
        startWakeWordService()
        
        // 🔥 BIENVENUE VOCAL UNIQUE
        // Message uniquement au premier lancement
        android.os.Handler().postDelayed({
            FirstLaunchWelcome.playWelcomeIfFirstLaunch(this)
        }, 800) // Délai pour stabilité
    }

    private fun setupToolbar() {
        setSupportActionBar(binding.toolbar)
    }

    private fun setupButtons() {
        binding.voiceButton.setOnClickListener {
            // TODO: Implement direct voice command
        }

        binding.settingsButton.setOnClickListener {
            // TODO: Open settings activity
        }
    }

    private fun startWakeWordService() {
        val intent = Intent(this, WakeWordService::class.java)
        startService(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
        // Cleanup if needed
    }
}
