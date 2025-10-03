package com.magiccontrol.utils

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.magiccontrol.tts.TTSManager
import com.magiccontrol.R

object FirstLaunchWelcome {
    private const val TAG = "FirstLaunchWelcome"
    private const val DELAY_AFTER_SOUND_MS = 100L  // 0.1s après le son

    /**
     * Joue le message de BIENVENUE uniquement au premier lancement
     */
    fun playWelcomeIfFirstLaunch(context: Context) {
        if (PreferencesManager.isFirstLaunch(context)) {
            Log.d(TAG, "Premier lancement détecté - planning message BIENVENUE")
            
            Handler(Looper.getMainLooper()).postDelayed({
                playWelcomeMessage(context)
            }, DELAY_AFTER_SOUND_MS)
            
        } else {
            Log.d(TAG, "Ce n'est pas le premier lancement - message BIENVENUE ignoré")
        }
    }

    private fun playWelcomeMessage(context: Context) {
        try {
            // Message BIENVENUE original
            val message = context.getString(R.string.welcome_message)
            Log.d(TAG, "Envoi message BIENVENUE: '$message'")
            
            TTSManager.speak(context, message)
            PreferencesManager.setFirstLaunchComplete(context)
            Log.d(TAG, "Premier lancement marqué comme terminé")
            
        } catch (e: Exception) {
            Log.e(TAG, "Erreur message BIENVENUE", e)
        }
    }
}
