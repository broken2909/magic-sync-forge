package com.magiccontrol

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.magiccontrol.service.WakeWordService
import com.magiccontrol.utils.WelcomeManager

class MainActivity : AppCompatActivity() {

    companion object {
        private const val PERMISSION_REQUEST_CODE = 123
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Welcome delayed pour TTS
        Handler(Looper.getMainLooper()).postDelayed({
            WelcomeManager.showWelcome(this)
        }, 1000)

        // Permissions micro seulement
        checkMicrophonePermission()

        // Configuration du bouton paramètres - TEMPORAIREMENT DÉSACTIVÉ
        setupSettingsButton()
    }

    private fun setupSettingsButton() {
        // TEMPORAIREMENT DÉSACTIVÉ - SettingsActivity n'est pas encore prêt
        findViewById<android.widget.Button>(R.id.settings_button)?.setOnClickListener {
            // TODO: Réactiver quand SettingsActivity sera prêt
            android.widget.Toast.makeText(this, "Paramètres bientôt disponibles", android.widget.Toast.LENGTH_SHORT).show()
        }
    }

    private fun checkMicrophonePermission() {
        val permissions = arrayOf(
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.MODIFY_AUDIO_SETTINGS
        )

        val missingPermissions = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }

        if (missingPermissions.isEmpty()) {
            // Permissions déjà accordées - démarrer le service
            startWakeWordService()
        } else {
            ActivityCompat.requestPermissions(this, missingPermissions.toTypedArray(), PERMISSION_REQUEST_CODE)
        }
    }

    private fun startWakeWordService() {
        try {
            val serviceIntent = Intent(this, WakeWordService::class.java)
            startService(serviceIntent)
        } catch (e: Exception) {
            android.widget.Toast.makeText(this, "Erreur démarrage service", android.widget.Toast.LENGTH_SHORT).show()
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
                startWakeWordService()
            } else {
                android.widget.Toast.makeText(this, "Permission microphone requise", android.widget.Toast.LENGTH_LONG).show()
            }
        }
    }
}
