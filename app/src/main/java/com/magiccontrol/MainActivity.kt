package com.magiccontrol

import android.content.Intent
import android.media.MediaPlayer
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // Son welcome personnalisé
        playWelcomeSound()
        
        // Welcome toast
        Toast.makeText(this, "Dites 'Magic' pour commencer", Toast.LENGTH_LONG).show()
        
        // Bouton settings
        findViewById<android.widget.Button>(R.id.settings_button)?.setOnClickListener {
            val intent = Intent(this, com.magiccontrol.ui.settings.SettingsActivity::class.java)
            startActivity(intent)
        }
        
        // Démarrer le service vocal
        startWakeWordService()
    }

    private fun playWelcomeSound() {
        try {
            val mediaPlayer = MediaPlayer.create(this, R.raw.welcome_sound)
            mediaPlayer?.start()
        } catch (e: Exception) {
            // Fallback silencieux si erreur
        }
    }

    private fun startWakeWordService() {
        val serviceIntent = Intent(this, com.magiccontrol.service.WakeWordService::class.java)
        startService(serviceIntent)
    }
}
