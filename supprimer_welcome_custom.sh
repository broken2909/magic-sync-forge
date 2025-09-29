#!/bin/bash
echo "🗑️ SUPPRESSION WELCOMEMANAGER PERSONNALISÉ"

# 1. Supprimer le fichier WelcomeManager.kt
rm -f app/src/main/java/com/magiccontrol/utils/WelcomeManager.kt

# 2. Supprimer les références dans MainActivity
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

        // ✅ INITIALISATION TTS
        TTSManager.initialize(this)
        
        // ✅ SON TOAST SEULEMENT POUR L'INSTANT
        playToastSound()
        checkMicrophonePermission()
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
        Toast.makeText(this, "Microphone autorisé", Toast.LENGTH_LONG).show()
    }

    private fun onMicrophoneDenied() {
        Toast.makeText(this, "Microphone refusé", Toast.LENGTH_LONG).show()
    }
}
ACTIVITY

echo "✅ WELCOMEMANAGER SUPPRIMÉ!"
echo "📊 État actuel:"
echo "   - ✅ WelcomeManager.kt supprimé"
echo "   - ✅ Références supprimées de MainActivity"
echo "   - ✅ Son toast conservé"
echo "   - ✅ Application stable sans welcome vocal"
echo ""
echo "🚀 Maintenant on peut recréer la fonction PROPREMENT!"
