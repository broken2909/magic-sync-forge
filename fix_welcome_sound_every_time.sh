#!/bin/bash
echo "🔧 CORRECTION - SON À CHAQUE OUVERTURE"

# Modifier MainActivity pour son à CHAQUE ouverture
cat > app/src/main/java/com/magiccontrol/MainActivity.kt << 'MAINACTIVITY'
package com.magiccontrol

import android.media.MediaPlayer
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.magiccontrol.utils.FirstLaunchWelcome

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // Activation du message vocal de bienvenue au premier lancement
        FirstLaunchWelcome.playWelcomeIfFirstLaunch(this)
        
        // Jouer le son de bienvenue à CHAQUE ouverture
        playWelcomeSound()
    }
    
    private fun playWelcomeSound() {
        try {
            val mediaPlayer = MediaPlayer.create(this, R.raw.welcome_sound)
            mediaPlayer?.setOnCompletionListener { it.release() }
            mediaPlayer?.start()
        } catch (e: Exception) {
            // Ignorer les erreurs de son - ne pas bloquer l'application
        }
    }
}
MAINACTIVITY

echo "✅ CORRECTION APPLIQUÉE :"
echo "• Son joué à CHAQUE ouverture de l'application"
echo "• Supprimé la condition isFirstLaunch() pour le son"

echo ""
echo "🔍 VÉRIFICATION :"
grep -A 3 "playWelcomeSound()" app/src/main/java/com/magiccontrol/MainActivity.kt
