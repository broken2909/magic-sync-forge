package com.magiccontrol

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.magiccontrol.ui.settings.SettingsActivity
import com.magiccontrol.utils.WelcomeManager

class MainActivity : AppCompatActivity() {

    companion object {
        private const val PERMISSION_REQUEST_CODE = 123
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // 1. LANÇER LE WELCOME IMMÉDIATEMENT (sans attendre les permissions)
        WelcomeManager.showWelcome(this)
        
        // 2. Configurer le bouton paramètres
        setupSettingsButton()
        
        // 3. Vérifier les permissions micro (en parallèle)
        checkMicrophonePermission()
    }
    
    private fun setupSettingsButton() {
        val settingsButton = findViewById<android.widget.Button>(R.id.settings_button)
        settingsButton.setOnClickListener {
            val intent = Intent(this, SettingsActivity::class.java)
            startActivity(intent)
        }
    }
    
    private fun checkMicrophonePermission() {
        val microphonePermissions = arrayOf(
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.MODIFY_AUDIO_SETTINGS
        )
        
        val missingMicrophone = microphonePermissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        
        if (missingMicrophone.isNotEmpty()) {
            // Demander la permission micro APRÈS le welcome
            ActivityCompat.requestPermissions(this, missingMicrophone.toTypedArray(), PERMISSION_REQUEST_CODE)
        } else {
            // Micro déjà autorisé - lancer les fonctionnalités vocales
            startVoiceFeatures()
        }
    }
    
    private fun startVoiceFeatures() {
        // Ici on lancera la détection du mot magique, etc.
        android.widget.Toast.makeText(this, "Fonctionnalités vocales activées", android.widget.Toast.LENGTH_SHORT).show()
    }
    
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            val microphoneGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            
            if (microphoneGranted) {
                startVoiceFeatures()
            } else {
                android.widget.Toast.makeText(this, "Fonctionnalités vocales limitées", android.widget.Toast.LENGTH_LONG).show()
            }
        }
    }
}
