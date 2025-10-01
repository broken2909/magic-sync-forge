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
