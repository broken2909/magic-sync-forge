#!/bin/bash
echo "🗑️ SUPPRESSION MESSAGE GUIDANCE DE FIRSTLAUNCHWELCOME"

# Recréer FirstLaunchWelcome sans le message guidance
cat > app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt << 'CLEAN_WELCOME'
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
            Log.d(TAG, "Premier lancement - Son et message bienvenue uniquement")
            
            // Son welcome et message bienvenue SEULEMENT
            val welcomeSound = loadWelcomeSound(context)
            welcomeSound?.play()
            
            val currentLanguage = PreferencesManager.getCurrentLanguage(context)
            val message = if (currentLanguage == "fr") {
                "Bienvenue dans Magic Control. Votre assistant vocal pour malvoyants."
            } else {
                "Welcome to Magic Control. Your voice assistant for visually impaired."
            }
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
CLEAN_WELCOME

echo ""
echo "✅ DOUBLON SUPPRIMÉ"
echo "📊 FirstLaunchWelcome maintenant : Son welcome + Message bienvenue uniquement"
echo ""
echo "🔍 VÉRIFICATION :"
grep -c "TTSManager.speak" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt | xargs echo "Nombre de messages TTS restants:"
