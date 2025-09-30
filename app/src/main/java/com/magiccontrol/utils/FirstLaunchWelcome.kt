package com.magiccontrol.utils

import android.content.Context
import android.util.Log
import com.magiccontrol.tts.TTSManager
import java.util.Locale

object FirstLaunchWelcome {
    private const val TAG = "FirstLaunchWelcome"
    
    /**
     * Joue le message de bienvenue uniquement au premier lancement
     */
    fun playWelcomeIfFirstLaunch(context: Context) {
        // Vérifier si c'est le premier lancement
        if (PreferencesManager.isFirstLaunch(context)) {
            Log.d(TAG, "Premier lancement détecté - Préparation message vocal")
            
            // Message fixe - Le TTS Android gère automatiquement la langue système
            val message = "Bienvenue dans votre assistant vocal MagicControl"
            
            // Jouer le message avec délai pour stabilité
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                try {
                    TTSManager.speak(context, message)
                    Log.d(TAG, "Message vocal envoyé: '$message'")
                } catch (e: Exception) {
                    Log.e(TAG, "Erreur lors de l'envoi au TTS", e)
                }
            }, 1500) // Délai de 1.5s pour la stabilité
            
            // Marquer le premier lancement comme terminé
            PreferencesManager.setFirstLaunchComplete(context)
            Log.d(TAG, "Premier lancement marqué comme terminé")
        } else {
            Log.d(TAG, "Ce n'est pas le premier lancement - message ignoré")
        }
    }
}
