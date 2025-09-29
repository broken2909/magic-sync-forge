package com.magiccontrol.welcome

import android.content.Context
import android.content.SharedPreferences
import android.media.MediaPlayer
import com.magiccontrol.tts.TTSManager

/**
 * Gestionnaire de bienvenue INDÉPENDANT
 * - Son toast à chaque ouverture
 * - Message vocal première fois seulement
 * - Aucune dépendance Vosk/reconnaissance vocale
 */
object AppWelcomeManager {
    private const val PREFS_WELCOME = "app_welcome_prefs"
    private const val KEY_WELCOME_SHOWN = "welcome_shown_v1"
    
    /**
     * Joue le son toast à chaque ouverture
     */
    fun playWelcomeSound(context: Context) {
        try {
            val mediaPlayer = MediaPlayer.create(context, R.raw.welcome_sound)
            mediaPlayer?.setOnCompletionListener { mp ->
                mp.release()
            }
            mediaPlayer?.start()
        } catch (e: Exception) {
            // Son non critique - ignore l'erreur
        }
    }
    
    /**
     * Vérifie si le message vocal doit être joué (première fois seulement)
     */
    fun shouldPlayWelcomeVoice(context: Context): Boolean {
        val prefs = context.getSharedPreferences(PREFS_WELCOME, Context.MODE_PRIVATE)
        return !prefs.getBoolean(KEY_WELCOME_SHOWN, false)
    }
    
    /**
     * Joue le message vocal de bienvenue (une seule fois)
     */
    fun playWelcomeVoice(context: Context) {
        if (shouldPlayWelcomeVoice(context)) {
            // ✅ TTS Android gère automatiquement la langue système
            TTSManager.speak(context, "Bienvenue dans votre assistant vocal MagicControl")
            markWelcomeShown(context)
        }
    }
    
    /**
     * Marque le welcome comme déjà vu
     */
    private fun markWelcomeShown(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_WELCOME, Context.MODE_PRIVATE)
        prefs.edit().putBoolean(KEY_WELCOME_SHOWN, true).apply()
    }
    
    /**
     * Reset pour tests (optionnel)
     */
    fun resetWelcome(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_WELCOME, Context.MODE_PRIVATE)
        prefs.edit().putBoolean(KEY_WELCOME_SHOWN, false).apply()
    }
}
