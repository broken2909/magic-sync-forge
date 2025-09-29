package com.magiccontrol

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.magiccontrol.service.WakeWordService
import com.magiccontrol.utils.WelcomeManager
import com.magiccontrol.tts.TTSManager

class MainActivity : AppCompatActivity() {

    // ✅ SYSTÈME PERMISSION AVEC FALLBACK
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

        // ✅ ÉTAPE 1: INITIALISATION TTS
        TTSManager.initialize(this)
        
        setupToolbar()
        setupButtons()
        
        // ✅ ÉTAPE 2: WELCOME VISUEL IMMÉDIAT
        showWelcomeToast()
        
        // ✅ ÉTAPE 3: VÉRIFICATION PERMISSION
        checkMicrophonePermission()
    }

    private fun setupToolbar() {
        val toolbar = findViewById<androidx.appcompat.widget.Toolbar>(R.id.toolbar)
        setSupportActionBar(toolbar)
    }

    private fun setupButtons() {
        val voiceButton = findViewById<android.widget.ImageButton>(R.id.voice_button)
        val settingsButton = findViewById<android.widget.Button>(R.id.settings_button)

        voiceButton.setOnClickListener {
            TTSManager.speak(this, "Commande vocale directe")
        }

        settingsButton.setOnClickListener {
            TTSManager.speak(this, "Paramètres")
        }
    }

    private fun showWelcomeToast() {
        if (WelcomeManager.shouldShowWelcome(this)) {
            val welcomeMessage = WelcomeManager.getWelcomeMessage()
            Toast.makeText(this, welcomeMessage, Toast.LENGTH_LONG).show()
            WelcomeManager.markWelcomeShown(this)
        } else {
            Toast.makeText(this, "MagicControl", Toast.LENGTH_LONG).show()
        }
    }

    private fun checkMicrophonePermission() {
        if (ContextCompat.checkSelfPermission(
                this,
                android.Manifest.permission.RECORD_AUDIO
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            // ✅ PERMISSION DÉJÀ ACCORDÉE
            onMicrophoneGranted()
        } else {
            // ✅ DEMANDER PERMISSION
            audioPermissionLauncher.launch(android.Manifest.permission.RECORD_AUDIO)
        }
    }

    private fun onMicrophoneGranted() {
        // ✅ ÉTAPE 4: WELCOME VOCAL APRÈS PERMISSION
        if (WelcomeManager.shouldShowWelcome(this)) {
            val welcomeMessage = WelcomeManager.getWelcomeMessage()
            TTSManager.speak(this, welcomeMessage)
        } else {
            TTSManager.speak(this, "MagicControl activé")
        }
        
        // ✅ ÉTAPE 5: SERVICES APRÈS WELCOME VOCAL
        android.os.Handler().postDelayed({
            startWakeWordService()
        }, 2000)
    }

    private fun onMicrophoneDenied() {
        Toast.makeText(this, "Microphone refusé - Mode limité", Toast.LENGTH_LONG).show()
        TTSManager.speak(this, "Fonctionnalités vocales désactivées")
        // ❌ SERVICES NON DÉMARRÉS
    }

    private fun startWakeWordService() {
        val intent = Intent(this, WakeWordService::class.java)
        startService(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
    }
}
