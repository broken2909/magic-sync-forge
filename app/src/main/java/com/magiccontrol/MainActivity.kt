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
            Toast.makeText(this, "Microphone refusé - Fonctionnalités limitées", Toast.LENGTH_LONG).show()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        setupToolbar()
        setupButtons()
        showWelcomeToast()
        checkMicrophonePermission()
    }

    private fun setupToolbar() {
        setSupportActionBar(findViewById(R.id.toolbar))
    }

    private fun setupButtons() {
        findViewById<android.widget.ImageButton>(R.id.voice_button)?.setOnClickListener {
            // TODO: Implement direct voice command
        }

        findViewById<android.widget.Button>(R.id.settings_button)?.setOnClickListener {
            val intent = Intent(this, com.magiccontrol.ui.settings.SettingsActivity::class.java)
            startActivity(intent)
        }
    }

    private fun showWelcomeToast() {
        Toast.makeText(this, R.string.welcome_message, Toast.LENGTH_LONG).show()
    }

    private fun checkMicrophonePermission() {
        when {
            ContextCompat.checkSelfPermission(
                this,
                android.Manifest.permission.RECORD_AUDIO
            ) == PackageManager.PERMISSION_GRANTED -> {
                startWakeWordService()
            }
            else -> {
                // Demander la permission
                audioPermissionLauncher.launch(android.Manifest.permission.RECORD_AUDIO)
            }
        }
    }

    private fun startWakeWordService() {
        val serviceIntent = Intent(this, com.magiccontrol.service.WakeWordService::class.java)
        startService(serviceIntent)
    }

    override fun onDestroy() {
        super.onDestroy()
        // Cleanup if needed
    }
}
