#!/bin/bash
echo "🗑️ SUPPRESSION COMPLÈTE FONCTION WELCOME"

# 1. Supprimer AppWelcomeManager
rm -f app/src/main/java/com/magiccontrol/welcome/AppWelcomeManager.kt
rmdir app/src/main/java/com/magiccontrol/welcome 2>/dev/null

# 2. Nettoyer MainActivity - garder seulement son toast
cat > app/src/main/java/com/magiccontrol/MainActivity.kt << 'ACTIVITY'
package com.magiccontrol

import android.content.Intent
import android.content.pm.PackageManager
import android.media.MediaPlayer
import android.os.Bundle
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.magiccontrol.tts.TTSManager

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

        // ✅ SON TOAST SEULEMENT
        playWelcomeSound()
        
        // ✅ INIT TTS (pour futures fonctionnalités)
        TTSManager.initialize(this)
        
        checkMicrophonePermission()
    }

    private fun playWelcomeSound() {
        try {
            val mediaPlayer = MediaPlayer.create(this, R.raw.welcome_sound)
            mediaPlayer?.setOnCompletionListener { mp ->
                mp.release()
            }
            mediaPlayer?.start()
        } catch (e: Exception) {
            // Son non critique
        }
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
ACTIVITY

echo "✅ FONCTION WELCOME COMPLÈTEMENT SUPPRIMÉE!"
echo "📊 État final:"
echo "   - ✅ AppWelcomeManager supprimé"
echo "   - ✅ Package welcome supprimé"
echo "   - ✅ MainActivity nettoyé (son toast seulement)"
echo "   - ✅ TTS initialisé pour futur usage"
echo "   - ✅ Application stable et simple"
