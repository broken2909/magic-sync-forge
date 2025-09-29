package com.magiccontrol

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.magiccontrol.tts.TTSManager
import com.magiccontrol.welcome.AppWelcomeManager

class MainActivity : AppCompatActivity() {

    private val audioPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        if (isGranted) {
            onMicrophoneGranted()
        } else {
            onMicrophoneDenied()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // ✅ INITIALISATION TTS
        TTSManager.initialize(this)
        
        // ✅ WELCOME INDÉPENDANT
        handleIndependentWelcome()
        checkMicrophonePermission()
    }

    private fun handleIndependentWelcome() {
        // ✅ SON TOAST À CHAQUE OUVERTURE
        AppWelcomeManager.playWelcomeSound(this)
        
        // ✅ MESSAGE VOCAL PREMIÈRE FOIS SEULEMENT
        AppWelcomeManager.playWelcomeVoice(this)
    }

    private fun checkMicrophonePermission() {
        if (ContextCompat.checkSelfPermission(
                this,
                android.Manifest.permission.RECORD_AUDIO
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            onMicrophoneGranted()
        } else {
            audioPermissionLauncher.launch(android.Manifest.permission.RECORD_AUDIO)
        }
    }

    private fun onMicrophoneGranted() {
        Toast.makeText(this, "Microphone autorisé", Toast.LENGTH_LONG).show()
    }

    private fun onMicrophoneDenied() {
        Toast.makeText(this, "Microphone refusé", Toast.LENGTH_LONG).show()
    }
}
