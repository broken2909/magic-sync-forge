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

        // ✅ SON TOAST IMMÉDIAT
        AppWelcomeManager.playWelcomeSound(this, R.raw.welcome_sound)
        
        // ✅ INITIALISATION TTS AVEC CALLBACK
        TTSManager.initialize(this)
        
        // ✅ DÉLAI POUR LAISSER TTS S'INITIALISER PUIS WELCOME VOCAL
        android.os.Handler().postDelayed({
            handleWelcomeVoice()
        }, 2000) // 2 secondes pour TTS
        
        checkMicrophonePermission()
    }

    private fun handleWelcomeVoice() {
        // ✅ WELCOME VOCAL UNIQUEMENT APRÈS INITIALISATION TTS
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
