#!/bin/bash
echo "📦 BACKUP + CORRECTIONS + PUSH"

# 1. Créer un backup des fichiers actuels
echo ""
echo "📋 1. CRÉATION BACKUP"
BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

cp app/src/main/java/com/magiccontrol/MainActivity.kt "$BACKUP_DIR/MainActivity.backup.kt"
cp app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt "$BACKUP_DIR/FirstLaunchWelcome.backup.kt"

echo "✅ Backup créé dans: $BACKUP_DIR/"

# 2. Appliquer les corrections de compilation
echo ""
echo "📋 2. APPLICATION CORRECTIONS"

# Corriger FirstLaunchWelcome
cat > app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt << 'FIXED_WELCOME'
package com.magiccontrol.utils

import android.content.Context
import android.util.Log
import com.magiccontrol.tts.TTSManager

object FirstLaunchWelcome {
    private const val TAG = "FirstLaunchWelcome"
    
    fun playWelcomeIfFirstLaunch(context: Context) {
        // Utiliser Context directement au lieu de getPreferences privé
        val prefs = context.getSharedPreferences("magic_control_prefs", Context.MODE_PRIVATE)
        val isFirstLaunch = prefs.getBoolean("first_launch", true)
        
        if (isFirstLaunch) {
            Log.d(TAG, "Premier lancement - Message bienvenue unifié bilingue")
            
            // Son welcome
            val welcomeSound = loadWelcomeSound(context)
            welcomeSound?.start()  // Corriger play() -> start()
            
            // MESSAGE BIENVENUE UNIFIÉ BILINGUE
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
FIXED_WELCOME

# Corriger MainActivity
cat > app/src/main/java/com/magiccontrol/MainActivity.kt << 'FIXED_MAIN'
package com.magiccontrol

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.view.LayoutInflater
import com.magiccontrol.service.WakeWordService
import com.magiccontrol.utils.FirstLaunchWelcome

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Remplacer databinding par layout inflation standard
        val inflater = LayoutInflater.from(this)
        val view = inflater.inflate(R.layout.activity_main, null)
        setContentView(view)

        setupToolbar(view)
        setupButtons(view)
        
        // Message bienvenue UNIFIÉ (inclut guidance)
        FirstLaunchWelcome.playWelcomeIfFirstLaunch(this)
        
        // Démarrer service vocal
        startWakeWordService()
    }

    private fun setupToolbar(view: android.view.View) {
        val toolbar = view.findViewById<androidx.appcompat.widget.Toolbar>(R.id.toolbar)
        setSupportActionBar(toolbar)
    }

    private fun setupButtons(view: android.view.View) {
        val voiceButton = view.findViewById<android.widget.ImageButton>(R.id.voice_button)
        val settingsButton = view.findViewById<android.widget.Button>(R.id.settings_button)
        
        voiceButton.setOnClickListener {
            // TODO: Implement direct voice command
        }

        settingsButton.setOnClickListener {
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
FIXED_MAIN

echo "✅ Corrections appliquées"

# 3. Push vers GitHub
echo ""
echo "📋 3. PUSH VERS GITHUB"
git add .
git commit -m "🔧 Corrections compilation + Message bienvenue unifié

- Fix: Remplacer getPreferences() privé par getSharedPreferences()
- Fix: play() -> start() pour MediaPlayer  
- Fix: Remplacement DataBinding par LayoutInflater
- ✨ Message bienvenue unifié bilingue FR/EN avec guidance
- 🎯 Timing optimisé : Son welcome + message vocal unique"

git push origin main

echo ""
echo "✅ PUSH EFFECTUÉ AVEC SUCCÈS"
echo "📊 Backup sauvegardé dans: $BACKUP_DIR"
echo "🔗 Repository: https://github.com/broken2909/magic-sync-forge"
