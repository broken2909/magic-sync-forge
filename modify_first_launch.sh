#!/bin/bash
echo "🔧 MODIFICATION FIRSTLAUNCHWELCOME - AJOUT MESSAGE ACCESSIBILITÉ"

# Créer la version modifiée de FirstLaunchWelcome
cat > app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt << 'MODIFIED'
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
                    
                    val accessibilityMessage = "MagicControl nécessite une activation manuelle dans les paramètres d'accessibilité pour contrôler votre appareil. Nous recommandons une assistance pour cette étape."
                    TTSManager.speak(context, accessibilityMessage)
                    
                    // Attendre la fin du message accessibilité
                    delay(5000) // Estimation durée message
                    
                    // Message bienvenue original APRÈS
                    val welcomeSound = loadWelcomeSound(context)
                    welcomeSound?.play()
                    
                    val message = "Bienvenue dans Magic Control. Votre assistant vocal pour malvoyants."
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
MODIFIED

echo ""
echo "✅ FIRSTLAUNCHWELCOME MODIFIÉ AVEC SUCCÈS"
echo "📊 CHANGEMENTS APPLIQUÉS :"
echo "1. Message accessibilité ajouté AVEC délai 1s"
echo "2. Timing géré avec Coroutines"
echo "3. Message bienvenue original APRÈS message accessibilité"
echo "4. Gestion erreurs améliorée"

echo ""
echo "🔍 VÉRIFICATION :"
grep -A 5 -B 5 "paramètres d'accessibilité" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt
