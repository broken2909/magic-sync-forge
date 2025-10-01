#!/bin/bash
echo "🔧 ACTIVATION SERVICE MICROPHONE"

# Ajouter le démarrage du service dans MainActivity
cat > app/src/main/java/com/magiccontrol/MainActivity.kt << 'MAINACTIVITY'
package com.magiccontrol

import android.content.Intent
import android.media.MediaPlayer
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.magiccontrol.service.WakeWordService
import com.magiccontrol.utils.FirstLaunchWelcome

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // Activation du message vocal de bienvenue au premier lancement
        FirstLaunchWelcome.playWelcomeIfFirstLaunch(this)
        
        // Jouer le son de bienvenue à CHAQUE ouverture
        playWelcomeSound()
        
        // DÉMARRER le service de détection vocale (demande permission micro)
        startWakeWordService()
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
    
    private fun startWakeWordService() {
        val intent = Intent(this, WakeWordService::class.java)
        startService(intent)
    }
}
MAINACTIVITY

echo "✅ SERVICE ACTIVÉ :"
echo "• WakeWordService démarré dans MainActivity"
echo "• L'app va maintenant demander l'autorisation micro"
echo "• Service de détection vocale activé"

echo ""
echo "🔍 VÉRIFICATION :"
grep -n "startWakeWordService\\|WakeWordService" app/src/main/java/com/magiccontrol/MainActivity.kt
