package com.magiccontrol

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.view.LayoutInflater
import com.magiccontrol.service.WakeWordService
import com.magiccontrol.utils.FirstLaunchWelcome

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Remplacer databinding par layout inflation standard
        val inflater = LayoutInflater.from(this)
        val view = inflater.inflate(R.layout.activity_main, null)
        setContentView(view)

        setupToolbar(view)
        setupButtons(view)
        
        // Message bienvenue UNIFIÉ (inclut guidance)
        FirstLaunchWelcome.playWelcomeIfFirstLaunch(this)
        
        // Démarrer service vocal
        startWakeWordService()
    }

    private fun setupToolbar(view: android.view.View) {
        val toolbar = view.findViewById<androidx.appcompat.widget.Toolbar>(R.id.toolbar)
        setSupportActionBar(toolbar)
    }

    private fun setupButtons(view: android.view.View) {
        val voiceButton = view.findViewById<android.widget.ImageButton>(R.id.voice_button)
        val settingsButton = view.findViewById<android.widget.Button>(R.id.settings_button)
        
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
    }
}
