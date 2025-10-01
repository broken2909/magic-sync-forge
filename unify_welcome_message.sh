#!/bin/bash
echo "🔧 CRÉATION MESSAGE BIENVENUE UNIFIÉ"

# 1. Supprimer complètement le message guidance isolé
echo "📋 1. SUPPRESSION MESSAGE GUIDANCE ISOLÉ"
cat > app/src/main/java/com/magiccontrol/MainActivity.kt << 'MAIN_CLEAN'
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
        
        // Message bienvenue UNIFIÉ (inclut guidance)
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
MAIN_CLEAN

# 2. Modifier FirstLaunchWelcome avec message UNIFIÉ
echo "📋 2. CRÉATION MESSAGE BIENVENUE UNIFIÉ"
cat > app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt << 'UNIFIED_WELCOME'
package com.magiccontrol.utils

import android.content.Context
import android.util.Log
import com.magiccontrol.tts.TTSManager

object FirstLaunchWelcome {
    private const val TAG = "FirstLaunchWelcome"
    
    fun playWelcomeIfFirstLaunch(context: Context) {
        val prefs = PreferencesManager.getPreferences(context)
        val isFirstLaunch = prefs.getBoolean("first_launch", true)
        
        if (isFirstLaunch) {
            Log.d(TAG, "Premier lancement - Message bienvenue unifié")
            
            // Son welcome
            val welcomeSound = loadWelcomeSound(context)
            welcomeSound?.play()
            
            // MESSAGE BIENVENUE UNIFIÉ (salutation + guidance)
            val currentLanguage = PreferencesManager.getCurrentLanguage(context)
            val unifiedMessage = if (currentLanguage == "fr") {
                "Bienvenue dans votre assistant vocal Magic Control. Magic Control nécessite une activation manuelle dans les paramètres d'accessibilité pour contrôler votre appareil. Nous recommandons une assistance pour cette étape."
            } else {
                "Welcome to your voice assistant Magic Control. Magic Control requires manual activation in accessibility settings to control your device. We recommend assistance for this step."
            }
            
            TTSManager.speak(context, unifiedMessage)
            
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
UNIFIED_WELCOME

echo ""
echo "✅ MESSAGE UNIFIÉ CRÉÉ"
echo "📊 Nouvelle structure :"
echo "   1. Son welcome_sound"
echo "   2. Message unifié : Bienvenue + Guidance"
echo "   3. Service vocal démarre après"
echo ""
echo "🔍 VÉRIFICATION SUPPRESSION :"
if grep -q "playGuidanceMessage" app/src/main/java/com/magiccontrol/MainActivity.kt; then
    echo "❌ Message guidance toujours présent"
else
    echo "✅ Message guidance complètement supprimé"
fi
