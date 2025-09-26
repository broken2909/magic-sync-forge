package com.magiccontrol

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.magiccontrol.service.WakeWordService

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        setupToolbar()
        setupButtons()
        // startWakeWordService() // DEBUG: Temporarily disabled
    }

    private fun setupToolbar() {
        val toolbar = findViewById<androidx.appcompat.widget.Toolbar>(R.id.toolbar)
        setSupportActionBar(toolbar)
    }

    private fun setupButtons() {
        val voiceButton = findViewById<android.widget.ImageButton>(R.id.voice_button)
        val settingsButton = findViewById<android.widget.Button>(R.id.settings_button)
        
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
