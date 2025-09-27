package com.magiccontrol.utils

import android.content.Context
import android.media.MediaPlayer
import android.util.Log
import android.widget.Toast
import java.util.Locale
import com.magiccontrol.tts.TTSManager

object WelcomeManager {
    private const val PREFS_WELCOME = "welcome_prefs"
    private const val KEY_FIRST_LAUNCH = "first_launch"
    private const val TAG = "WelcomeManager"
    
    fun showWelcome(context: Context) {
        Log.d(TAG, "=== DÉBUT WELCOME ===")
        val prefs = context.getSharedPreferences(PREFS_WELCOME, Context.MODE_PRIVATE)

        // 1. Son personnalisé
        Log.d(TAG, "1. Jouer son")
        playCustomSound(context)
        
        // 2. Vérifier premier lancement
        val isFirstLaunch = prefs.getBoolean(KEY_FIRST_LAUNCH, true)
        Log.d(TAG, "2. Premier lancement: $isFirstLaunch")
        
        if (isFirstLaunch) {
            Log.d(TAG, "3. Premier lancement détecté")
            showFirstLaunchWelcome(context)
            prefs.edit().putBoolean(KEY_FIRST_LAUNCH, false).apply()
            Log.d(TAG, "4. Premier lancement enregistré")
        }
        Log.d(TAG, "=== FIN WELCOME ===")
    }
    
    private fun playCustomSound(context: Context) {
        try {
            val mediaPlayer = MediaPlayer.create(context, android.net.Uri.parse("android.resource://com.magiccontrol/raw/welcome_sound"))
            if (mediaPlayer == null) {
                Log.e(TAG, "MediaPlayer null")
            } else {
                mediaPlayer.setOnCompletionListener { player: MediaPlayer ->
                    player.release()
                    Log.d(TAG, "Son terminé")
                }
                mediaPlayer.start()
                Log.d(TAG, "Son démarré")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erreur son: ${e.message}")
            val message = when (Locale.getDefault().language) {
                "fr" -> "MagicControl activé"
                "en" -> "MagicControl activated" 
                else -> "MagicControl ready"
            }
            Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
        }
    }
    
    private fun showFirstLaunchWelcome(context: Context) {
        Log.d(TAG, "Début welcome vocal")
        val lang = Locale.getDefault().language
        val message = when {
            lang.startsWith("fr") -> "Bienvenue dans MagicControl. Dites Magic pour commencer."
            lang.startsWith("en") -> "Welcome to MagicControl. Say Magic to begin."
            else -> "Welcome to MagicControl. Say Magic to begin."
        }
        
        Log.d(TAG, "Message: $message")
        
        // Appel direct à TTSManager
        TTSManager.speak(context, message)
        Log.d(TAG, "TTSManager.speak() appelé")
    }
}
