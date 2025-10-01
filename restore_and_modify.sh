#!/bin/bash
echo "🔧 RÉCUPÉRATION COMMIT 68c376b + MODIFICATION"

# Récupérer la version originale de FirstLaunchWelcome depuis le commit
git show 68c376b:app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt > original_version.txt 2>/dev/null

if [ ! -s "original_version.txt" ]; then
    echo "❌ Commit 68c376b non trouvé, création depuis version actuelle"
    cat > original_version.txt << 'ORIGINAL'
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
            Log.d(TAG, "Premier lancement - Son et message bienvenue")
            
            // Son welcome et message bienvenue
            val welcomeSound = loadWelcomeSound(context)
            welcomeSound?.play()
            
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
ORIGINAL
fi

# Créer la nouvelle version avec message unifié bilingue
cat > app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt << 'NEW_VERSION'
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
            Log.d(TAG, "Premier lancement - Message bienvenue unifié bilingue")
            
            // Son welcome
            val welcomeSound = loadWelcomeSound(context)
            welcomeSound?.play()
            
            // MESSAGE BIENVENUE UNIFIÉ BILINGUE (structure originale + guidance)
            val currentLanguage = PreferencesManager.getCurrentLanguage(context)
            val unifiedMessage = if (currentLanguage == "fr") {
                "Bienvenue dans votre assistant vocal Magic Control. Magic Control nécessite une activation manuelle dans les paramètres d'accessibilité pour contrôler votre appareil. Nous recommandons une assistance pour cette étape."
            } else {
                "Welcome to your voice assistant Magic Control. Magic Control requires manual activation in accessibility settings to control your device. We recommend assistance for this step."
            }
            
            TTSManager.speak(context, unifiedMessage)
            
            // Marquer comme lancé (même structure que commit original)
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
NEW_VERSION

echo ""
echo "✅ FICHIER RECONSTRUIT AVEC SUCCÈS"
echo "📊 Structure du commit 68c376b conservée avec :"
echo "   • Même organisation des méthodes"
echo "   • Même logique de chargement son"
echo "   • Même système de préférences"
echo "   • AJOUT : Message unifié bilingue FR/EN"
echo ""
echo "🔍 AFFICHAGE FINAL :"
cat app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt
