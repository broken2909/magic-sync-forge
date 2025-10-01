#!/bin/bash
echo "🔧 CORRECTION RÉFÉRENCE MANQUANTE 'R'"

# Ajouter l'import manquant pour R
cat > app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt << 'WELCOME'
package com.magiccontrol.utils

import android.content.Context
import android.util.Log
import com.magiccontrol.tts.TTSManager
import com.magiccontrol.R

object FirstLaunchWelcome {
    private const val TAG = "FirstLaunchWelcome"

    /**
     * Joue le message de bienvenue uniquement au premier lancement
     */
    fun playWelcomeIfFirstLaunch(context: Context) {
        // Vérifier si c'est le premier lancement
        if (PreferencesManager.isFirstLaunch(context)) {
            Log.d(TAG, "Premier lancement détecté")
            
            // Initialiser TTS avant de parler
            TTSManager.initialize(context)
            
            // Message MULTILINGUE via ressources système
            val message = context.getString(R.string.welcome_message)
            
            // Jouer le message
            try {
                TTSManager.speak(context, message)
                Log.d(TAG, "Message vocal envoyé: '$message'")
            } catch (e: Exception) {
                Log.e(TAG, "Erreur lors de l'envoi au TTS", e)
            }
            
            // Marquer le premier lancement comme terminé
            PreferencesManager.setFirstLaunchComplete(context)
            Log.d(TAG, "Premier lancement marqué comme terminé")
        } else {
            Log.d(TAG, "Ce n'est pas le premier lancement - message ignoré")
        }
    }
}
WELCOME

echo "✅ CORRECTION APPLIQUÉE :"
echo "• Import com.magiccontrol.R AJOUTÉ"
echo "• Référence R.string.welcome_message MAINTENANT VALIDE"

echo ""
echo "🔍 VÉRIFICATION :"
grep -n "import.*R" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt
grep -n "R.string.welcome_message" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt
