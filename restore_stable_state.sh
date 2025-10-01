#!/bin/bash
echo "🔄 RESTAURATION ÉTAT STABLE - AVANT MESSAGE GUIDANCE"

# Créer un backup de l'état actuel
echo ""
echo "📦 BACKUP ÉTAT ACTUEL"
CURRENT_BACKUP="backup_current_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$CURRENT_BACKUP"

cp app/src/main/java/com/magiccontrol/MainActivity.kt "$CURRENT_BACKUP/"
cp app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt "$CURRENT_BACKUP/"
cp app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt "$CURRENT_BACKUP/"

echo "✅ Backup actuel créé: $CURRENT_BACKUP"

# Restaurer WakeWordDetector depuis backup Vosk (état stable)
echo ""
echo "🔧 RESTAURATION WAKEWORDDETECTOR (Stable)"
cp backup_vosk_20251001_171203/WakeWordDetector.backup.kt app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

# Recréer MainActivity version simple sans guidance
echo "🔧 CRÉATION MAINACTIVITY (Version simple)"
cat > app/src/main/java/com/magiccontrol/MainActivity.kt << 'MAIN_SIMPLE'
package com.magiccontrol

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.magiccontrol.databinding.ActivityMainBinding
import com.magiccontrol.service.WakeWordService
import com.magiccontrol.utils.FirstLaunchWelcome

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setupToolbar()
        setupButtons()
        
        // Message bienvenue simple
        FirstLaunchWelcome.playWelcomeIfFirstLaunch(this)
        
        // Démarrer service vocal
        startWakeWordService()
    }

    private fun setupToolbar() {
        setSupportActionBar(binding.toolbar)
    }

    private fun setupButtons() {
        binding.voiceButton.setOnClickListener {
            // TODO: Implement direct voice command
        }

        binding.settingsButton.setOnClickListener {
            // TODO: Open settings activity
        }
    }

    private fun startWakeWordService() {
        val intent = Intent(this, WakeWordService::class.java)
        startService(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
    }
}
MAIN_SIMPLE

# Recréer FirstLaunchWelcome version simple sans guidance
echo "🔧 CRÉATION FIRSTLAUNCHWELCOME (Version simple)"
cat > app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt << 'WELCOME_SIMPLE'
package com.magiccontrol.utils

import android.content.Context
import android.util.Log
import com.magiccontrol.tts.TTSManager

object FirstLaunchWelcome {
    private const val TAG = "FirstLaunchWelcome"
    
    fun playWelcomeIfFirstLaunch(context: Context) {
        val prefs = context.getSharedPreferences("magic_control_prefs", Context.MODE_PRIVATE)
        val isFirstLaunch = prefs.getBoolean("first_launch", true)
        
        if (isFirstLaunch) {
            Log.d(TAG, "Premier lancement - Son et message bienvenue")
            
            // Son welcome et message bienvenue simple
            val welcomeSound = loadWelcomeSound(context)
            welcomeSound?.start()
            
            val message = "Bienvenue dans Magic Control. Votre assistant vocal pour malvoyants."
            TTSManager.speak(context, message)
            
            // Marquer comme lancé
            prefs.edit().putBoolean("first_launch", false).apply()
        }
    }
    
    private fun loadWelcomeSound(context: Context): android.media.MediaPlayer? {
        return try {
            val soundResource = context.resources.getIdentifier("welcome_sound", "raw", context.packageName)
            if (soundResource != 0) {
                android.media.MediaPlayer.create(context, soundResource)
            } else {
                Log.w(TAG, "Son de bienvenue non trouvé")
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erreur chargement son bienvenue", e)
            null
        }
    }
}
WELCOME_SIMPLE

echo ""
echo "✅ RESTAURATION TERMINÉE"
echo "📊 État stable restauré - AVANT message guidance"
echo "🔍 VÉRIFICATION:"
echo "MainActivity - Guidance: $(grep -c "activation manuelle" app/src/main/java/com/magiccontrol/MainActivity.kt)"
echo "FirstLaunchWelcome - Guidance: $(grep -c "activation manuelle" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt)"
echo "WakeWordDetector - Constructeur: $(grep -c "Model(context.assets" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt)"
