package com.magiccontrol

import android.content.Intent
import android.content.pm.PackageManager
import android.media.MediaPlayer
import android.os.Bundle
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.magiccontrol.service.WakeWordService
import com.magiccontrol.utils.FirstLaunchWelcome

class MainActivity : AppCompatActivity() {
    
    // Contrat pour la demande de permission
    private val requestPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        if (isGranted) {
            // Permission accordée - démarrer le service
            startWakeWordService()
        } else {
            // Permission refusée
            android.util.Log.w("MainActivity", "Permission microphone refusée")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // Activation du message vocal de bienvenue au premier lancement
        FirstLaunchWelcome.playWelcomeIfFirstLaunch(this)
        
        // Jouer le son de bienvenue à CHAQUE ouverture
        playWelcomeSound()
        
        // DEMANDER la permission micro
        requestMicrophonePermission()
    }
    
    private fun playWelcomeSound() {
        try {
            val mediaPlayer = MediaPlayer.create(this, R.raw.welcome_sound)
            mediaPlayer?.setOnCompletionListener { it.release() }
            mediaPlayer?.start()
        } catch (e: Exception) {
            // Ignorer les erreurs de son
        }
    }
    
    private fun requestMicrophonePermission() {
        when {
            ContextCompat.checkSelfPermission(
                this,
                android.Manifest.permission.RECORD_AUDIO
            ) == PackageManager.PERMISSION_GRANTED -> {
                // Permission déjà accordée - démarrer le service
                startWakeWordService()
            }
            else -> {
                // Demander la permission
                requestPermissionLauncher.launch(android.Manifest.permission.RECORD_AUDIO)
            }
        }
    }
    
    private fun startWakeWordService() {
        val intent = Intent(this, WakeWordService::class.java)
        startService(intent)
    }
}
