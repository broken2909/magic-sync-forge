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

        // Son joyeux à chaque ouverture (remplace le toast vocal)
        playHappySound(context)
        
        if (prefs.getBoolean(KEY_FIRST_LAUNCH, true)) {
            // Première utilisation - message vocal personnalisé
            showFirstLaunchWelcome(context)
            prefs.edit().putBoolean(KEY_FIRST_LAUNCH, false).apply()
        }
    }
    
    private fun playHappySound(context: Context) {
        try {
            // Son court et joyeux (son système de notification)
            val notificationUri = android.provider.Settings.System.DEFAULT_NOTIFICATION_URI
            val mediaPlayer = MediaPlayer.create(context, notificationUri)
            mediaPlayer?.setOnCompletionListener { player ->
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
        }
    }
    
    private fun showFirstLaunchWelcome(context: Context) {
        val systemLang = Locale.getDefault().language
        val welcomeMessage = when {
            systemLang.startsWith("fr") -> "Bienvenue dans MagicControl, votre assistant vocal offline. Dites le mot magique pour commencer."
            systemLang.startsWith("en") -> "Welcome to MagicControl, your offline voice assistant. Say the magic word to begin."
            else -> "Welcome to MagicControl. Say the magic word to begin."
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
