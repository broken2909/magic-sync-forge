package com.magiccontrol.utils

import android.content.Context
import android.media.MediaPlayer
import android.widget.Toast
import java.util.Locale

object WelcomeManager {
    private const val PREFS_WELCOME = "welcome_prefs"
    private const val KEY_FIRST_LAUNCH = "first_launch"
    
    fun showWelcome(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_WELCOME, Context.MODE_PRIVATE)

        // Son personnalisé à chaque ouverture
        playCustomSound(context)
        
        if (prefs.getBoolean(KEY_FIRST_LAUNCH, true)) {
            // Première utilisation - message vocal personnalisé
            showFirstLaunchWelcome(context)
            prefs.edit().putBoolean(KEY_FIRST_LAUNCH, false).apply()
        }
    }
    
    private fun playCustomSound(context: Context) {
        try {
            // Utiliser le son personnalisé via Resources
            val mediaPlayer = MediaPlayer.create(context, android.net.Uri.parse("android.resource://com.magiccontrol/raw/welcome_sound"))
            mediaPlayer?.setOnCompletionListener { player: MediaPlayer ->
                player.release()
            }
            mediaPlayer?.start()
        } catch (e: Exception) {
            // Fallback sur un toast visuel si le son échoue
            val systemLang = Locale.getDefault().language
            val message = when {
                systemLang.startsWith("fr") -> "MagicControl activé"
                systemLang.startsWith("en") -> "MagicControl activated"
                else -> "MagicControl ready"
            }
            Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
            android.util.Log.e("WelcomeManager", "Erreur son personnalisé: ${e.message}")
        }
    }
    
    private fun showFirstLaunchWelcome(context: Context) {
        val systemLang = Locale.getDefault().language
        val welcomeMessage = when {
            systemLang.startsWith("fr") -> "Bienvenue dans MagicControl, votre assistant vocal offline. Dites Magic pour commencer."
            systemLang.startsWith("en") -> "Welcome to MagicControl, your offline voice assistant. Say Magic to begin."
            else -> "Welcome to MagicControl. Say Magic to begin."
        }
        
        // Utiliser le TTS existant mais de manière isolée
        try {
            val ttsManager = Class.forName("com.magiccontrol.tts.TTSManager")
            val speakMethod = ttsManager.getDeclaredMethod("speak", Context::class.java, String::class.java)
            speakMethod.invoke(null, context, welcomeMessage)
        } catch (e: Exception) {
            // Fallback silencieux si TTS échoue
            android.util.Log.d("WelcomeManager", "TTS non disponible: ${e.message}")
        }
    }
}
