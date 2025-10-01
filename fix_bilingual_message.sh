#!/bin/bash
echo "🔧 CORRECTION MESSAGE BILINGUE FR/EN"

# Modifier FirstLaunchWelcome pour le message bilingue
cat > app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt << 'BILINGUAL'
package com.magiccontrol.utils

import android.content.Context
import android.util.Log
import com.magiccontrol.tts.TTSManager
import kotlinx.coroutines.*

object FirstLaunchWelcome {
    private const val TAG = "FirstLaunchWelcome"
    
    fun playWelcomeMessage(context: Context) {
        val prefs = PreferencesManager.getPreferences(context)
        val isFirstLaunch = prefs.getBoolean("first_launch", true)
        
        if (isFirstLaunch) {
            Log.d(TAG, "Premier lancement - Lecture message bienvenue")
            
            // Initialiser TTS avant de parler
            TTSManager.initialize(context)
            
            // Utiliser Coroutines pour gérer le timing
            CoroutineScope(Dispatchers.Main).launch {
                try {
                    // Message guidance accessibilité AVEC DELAI
                    delay(1000) // Attendre 1s après initialisation TTS
                    
                    // MESSAGE BILINGUE selon la langue système
                    val currentLanguage = PreferencesManager.getCurrentLanguage(context)
                    val accessibilityMessage = if (currentLanguage == "fr") {
                        "MagicControl nécessite une activation manuelle dans les paramètres d'accessibilité pour contrôler votre appareil. Nous recommandons une assistance pour cette étape."
                    } else {
                        "MagicControl requires manual activation in accessibility settings to control your device. We recommend assistance for this step."
                    }
                    
                    TTSManager.speak(context, accessibilityMessage)
                    
                    // Attendre la fin du message accessibilité
                    delay(5000) // Estimation durée message
                    
                    // Message bienvenue original APRÈS (déjà dans la bonne langue via TTSManager)
                    val welcomeSound = loadWelcomeSound(context)
                    welcomeSound?.play()
                    
                    val message = if (currentLanguage == "fr") {
                        "Bienvenue dans Magic Control. Votre assistant vocal pour malvoyants."
                    } else {
                        "Welcome to Magic Control. Your voice assistant for visually impaired."
                    }
                    TTSManager.speak(context, message)
                    
                    // Marquer comme lancé
                    prefs.edit().putBoolean("first_launch", false).apply()
                    Log.d(TAG, "Messages bienvenue terminés")
                    
                } catch (e: Exception) {
                    Log.e(TAG, "Erreur lors de l'envoi au TTS", e)
                }
            }
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
BILINGUAL

echo ""
echo "✅ MESSAGE BILINGUE APPLIQUÉ"
echo "📊 Français : Activation manuelle recommandée"
echo "📊 English : Manual activation recommended"
echo ""
echo "🔍 VÉRIFICATION :"
grep -A 3 "MESSAGE BILINGUE" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt
