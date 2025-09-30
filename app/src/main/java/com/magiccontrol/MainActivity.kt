package com.magiccontrol

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.ImageButton
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar
import com.magiccontrol.service.WakeWordService
import com.magiccontrol.utils.FirstLaunchWelcome

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Récupérer les vues avec findViewById
        val toolbar: Toolbar = findViewById(R.id.toolbar)
        val voiceButton: ImageButton = findViewById(R.id.voice_button)
        val settingsButton: Button = findViewById(R.id.settings_button)

        setupToolbar(toolbar)
        setupButtons(voiceButton, settingsButton)
        // startWakeWordService() // 🚨 TEST: Désactivé temporairement
        
        // 🔥 BIENVENUE VOCAL UNIQUE
        android.os.Handler().postDelayed({
            FirstLaunchWelcome.playWelcomeIfFirstLaunch(this)
        }, 800)
    }

    private fun setupToolbar(toolbar: Toolbar) {
        setSupportActionBar(toolbar)
    }

    private fun setupButtons(voiceButton: ImageButton, settingsButton: Button) {
        voiceButton.setOnClickListener {
            // TODO: Implement direct voice command
        }

        settingsButton.setOnClickListener {
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
