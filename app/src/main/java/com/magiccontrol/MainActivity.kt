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
import com.magiccontrol.ui.settings.SettingsActivity
import com.magiccontrol.utils.WelcomeManager

class MainActivity : AppCompatActivity() {

    companion object {
        private const val PERMISSION_REQUEST_CODE = 123
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // 1. Configurer le bouton paramètres
        setupSettingsButton()
        
        // 2. Attendre 1 seconde que TTS s'initialise, PUIS lancer le welcome
        Handler(Looper.getMainLooper()).postDelayed({
            WelcomeManager.showWelcome(this)
        }, 1000)
        
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
            ActivityCompat.requestPermissions(this, missingMicrophone.toTypedArray(), PERMISSION_REQUEST_CODE)
        } else {
            startVoiceFeatures()
        }
    }
    
    private fun startVoiceFeatures() {
        android.widget.Toast.makeText(this, "Fonctionnalités vocales activées", android.widget.Toast.LENGTH_SHORT).show()
    }
    
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
                startVoiceFeatures()
            } else {
                android.widget.Toast.makeText(this, "Fonctionnalités vocales limitées", android.widget.Toast.LENGTH_LONG).show()
            }
        }
    }
}
