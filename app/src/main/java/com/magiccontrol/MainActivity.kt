package com.magiccontrol

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat

class MainActivity : AppCompatActivity() {

    private val audioPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        if (isGranted) {
            startWakeWordService()
            Toast.makeText(this, "Microphone autorisé", Toast.LENGTH_SHORT).show()
        } else {
            Toast.makeText(this, "Microphone refusé", Toast.LENGTH_SHORT).show()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        showWelcomeToast()
        setupToolbar()
        setupButtons()
        checkMicrophonePermission()
    }

    private fun setupToolbar() {
        // Vérification si la toolbar existe
        val toolbar = findViewById<androidx.appcompat.widget.Toolbar>(R.id.toolbar)
        if (toolbar != null) {
            setSupportActionBar(toolbar)
        }
    }

    private fun setupButtons() {
        // Bouton vocal
        val voiceButton = findViewById<android.widget.ImageButton>(R.id.voice_button)
        voiceButton?.setOnClickListener {
            Toast.makeText(this, "Bouton vocal", Toast.LENGTH_SHORT).show()
        }

        // Bouton paramètres
        val settingsButton = findViewById<android.widget.Button>(R.id.settings_button)
        settingsButton?.setOnClickListener {
            val intent = Intent(this, com.magiccontrol.ui.settings.SettingsActivity::class.java)
            startActivity(intent)
        }
    }

    private fun showWelcomeToast() {
        Toast.makeText(this, R.string.welcome_message, Toast.LENGTH_LONG).show()
    }

    private fun checkMicrophonePermission() {
        if (ContextCompat.checkSelfPermission(
                this,
                android.Manifest.permission.RECORD_AUDIO
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            startWakeWordService()
        } else {
            audioPermissionLauncher.launch(android.Manifest.permission.RECORD_AUDIO)
        }
    }

    private fun startWakeWordService() {
        val serviceIntent = Intent(this, com.magiccontrol.service.WakeWordService::class.java)
        startService(serviceIntent)
    }
}
