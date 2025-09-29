#!/bin/bash
echo "🎵 AJOUT SON TOAST WELCOME PARTAGÉ"

# Ajouter seulement la lecture du son pour le toast welcome
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
import com.magiccontrol.utils.WelcomeManager

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

        // ✅ TOAST WELCOME AVEC SON
        showWelcomeWithSound()
        checkMicrophonePermission()
    }

    private fun showWelcomeWithSound() {
        if (WelcomeManager.shouldShowWelcome(this)) {
            val welcomeMessage = WelcomeManager.getWelcomeMessage()
            
            // ✅ SON TOAST WELCOME (fichier partagé)
            playToastSound()
            
            Toast.makeText(this, welcomeMessage, Toast.LENGTH_LONG).show()
            WelcomeManager.markWelcomeShown(this)
        } else {
            Toast.makeText(this, "MagicControl", Toast.LENGTH_LONG).show()
        }
    }

    private fun playToastSound() {
        try {
            // ✅ UTILISE LE FICHIER SON PARTAGÉ welcome_sound.mp3
            val mediaPlayer = MediaPlayer.create(this, R.raw.welcome_sound)
            mediaPlayer?.setOnCompletionListener { mp ->
                mp.release() // Libère les ressources après lecture
            }
            mediaPlayer?.start()
        } catch (e: Exception) {
            // Son non critique - l'app continue
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
        Toast.makeText(this, "✅ Microphone autorisé", Toast.LENGTH_LONG).show()
    }

    private fun onMicrophoneDenied() {
        Toast.makeText(this, "❌ Microphone refusé - Mode limité", Toast.LENGTH_LONG).show()
    }
}
FILE1

echo "✅ SON TOAST WELCOME AJOUTÉ!"
echo "📊 Configuration:"
echo "   - ✅ Fichier: welcome_sound.mp3 (partagé)"
echo "   - ✅ Lecture: Au toast welcome + détection langue"
echo "   - ✅ Gestion erreur: Son non bloquant"
echo ""
echo "🚀 Push pour tester le toast avec son!"
