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
            
            // Son welcome
            val welcomeSound = loadWelcomeSound(context)
            welcomeSound?.start()
            
            // Message bienvenue simple
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
