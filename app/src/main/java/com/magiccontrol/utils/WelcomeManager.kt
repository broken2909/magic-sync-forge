package com.magiccontrol.utils

import android.content.Context
import android.media.MediaPlayer
import android.speech.tts.TextToSpeech
import android.widget.Toast
import java.util.Locale

object WelcomeManager {
    private const val PREFS_WELCOME = "welcome_prefs"
    private const val KEY_FIRST_LAUNCH = "first_launch"
    
    fun showWelcome(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_WELCOME, Context.MODE_PRIVATE)

        // 1. Son personnalisé simple
        playCustomSound(context)
        
        // 2. Welcome vocal seulement au premier lancement
        if (prefs.getBoolean(KEY_FIRST_LAUNCH, true)) {
            showFirstLaunchWelcome(context)
            prefs.edit().putBoolean(KEY_FIRST_LAUNCH, false).apply()
        }
    }
    
    private fun playCustomSound(context: Context) {
        try {
            val mediaPlayer = MediaPlayer.create(context, android.net.Uri.parse("android.resource://com.magiccontrol/raw/welcome_sound"))
            mediaPlayer?.setOnCompletionListener { it.release() }
            mediaPlayer?.start()
        } catch (e: Exception) {
            val message = if (Locale.getDefault().language.startsWith("fr")) "MagicControl activé" else "MagicControl activated"
            Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
        }
    }
    
    private fun showFirstLaunchWelcome(context: Context) {
        val message = if (Locale.getDefault().language.startsWith("fr")) 
            "Bienvenue dans MagicControl. Dites Magic pour commencer." 
        else 
            "Welcome to MagicControl. Say Magic to begin."
        
        // TTS direct et simple
        val tts = TextToSpeech(context) { status ->
            if (status == TextToSpeech.SUCCESS) {
                tts.language = Locale.getDefault()
                tts.speak(message, TextToSpeech.QUEUE_FLUSH, null, "welcome")
            }
        }
    }
}
