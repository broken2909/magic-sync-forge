#!/bin/bash
echo "🔧 CORRECTION MAINACTIVITY SANS WELCOMEMANAGER"

# Recréer MainActivity sans référence à WelcomeManager
cat > app/src/main/java/com/magiccontrol/MainActivity.kt << 'FILE1'
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

        // ✅ INITIALISATION TTS
        TTSManager.initialize(this)
        
        // ✅ WELCOME SIMPLE AVEC TTS
        showWelcomeWithTTS()
        checkMicrophonePermission()
    }

    private fun showWelcomeWithTTS() {
        // ✅ APPROCHE ORIGINALE : Message fixe + TTS auto-détection langue
        val welcomeMessage = getString(R.string.welcome_message)
        
        // ✅ SON TOAST + SYNTHÈSE VOCALE
        playToastSound()
        TTSManager.speak(this, welcomeMessage)
    }

    private fun playToastSound() {
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
        TTSManager.speak(this, "Microphone autorisé, MagicControl prêt")
    }

    private fun onMicrophoneDenied() {
        Toast.makeText(this, "❌ Microphone refusé - Mode limité", Toast.LENGTH_LONG).show()
    }
}
FILE1

echo "✅ MAINACTIVITY CORRIGÉ!"
echo "📊 Approche originale restaurée:"
echo "   - ✅ Utilise R.string.welcome_message"
echo "   - ✅ TTS gère automatiquement la langue"
echo "   - ✅ Plus de WelcomeManager personnalisé"
echo "   - ✅ Son welcome_sound conservé"
echo ""
echo "🚀 Maintenant TTS détectera automatiquement la langue système!"
