package com.magiccontrol.welcome

import android.content.Context
import android.content.SharedPreferences
import android.media.MediaPlayer
import android.widget.Toast
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
     * @param soundResId ID de la ressource son (passé depuis Activity)
     */
    fun playWelcomeSound(context: Context, soundResId: Int) {
        try {
            if (soundResId != 0) {
                val mediaPlayer = MediaPlayer.create(context, soundResId)
                mediaPlayer?.setOnCompletionListener { mp ->
                    mp.release()
                }
                mediaPlayer?.start()
            }
        } catch (e: Exception) {
            // Son non critique - ignore l'erreur
        }
    }
    
    /**
     * Vérifie si le message vocal doit être joué (première fois seulement)
     */
    fun shouldPlayWelcomeVoice(context: Context): Boolean {
        val prefs = context.getSharedPreferences(PREFS_WELCOME, Context.MODE_PRIVATE)
        val shouldShow = !prefs.getBoolean(KEY_WELCOME_SHOWN, false)
        
        // ✅ DEBUG: Afficher l'état dans un toast
        Toast.makeText(context, "Debug: shouldShowWelcome = $shouldShow", Toast.LENGTH_LONG).show()
        
        return shouldShow
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
        Toast.makeText(context, "Welcome reseté", Toast.LENGTH_SHORT).show()
    }
}
