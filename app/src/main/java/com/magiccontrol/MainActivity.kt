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
            
            Handler(Looper.getMainLooper()).postDelayed({
                android.widget.Toast.makeText(
                    this, 
                    "Magic Control activé. Dites 'magic' pour commencer.", 
                    android.widget.Toast.LENGTH_SHORT
                ).show()
            }, 500)
        } catch (e: Exception) {
            android.widget.Toast.makeText(
                this, 
                "Erreur démarrage service: ${e.message}", 
                android.widget.Toast.LENGTH_LONG
            ).show()
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
                startWakeWordService()
            } else {
                android.widget.Toast.makeText(
                    this, 
                    "Permission microphone requise pour la reconnaissance vocale", 
                    android.widget.Toast.LENGTH_LONG
                ).show()
            }
        }
    }
}
