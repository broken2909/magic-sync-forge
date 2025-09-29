#!/bin/bash
echo "🔧 CORRECTION TIMING TTS"

# Modifier MainActivity pour attendre que TTS soit initialisé
cat > app/src/main/java/com/magiccontrol/MainActivity.kt << 'ACTIVITY'
package com.magiccontrol

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.magiccontrol.tts.TTSManager
import com.magiccontrol.welcome.AppWelcomeManager

class MainActivity : AppCompatActivity() {

    private val audioPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        if (isGranted) {
            onMicrophoneGranted()
        } else {
            onMicrophoneDenied()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // ✅ SON TOAST IMMÉDIAT
        AppWelcomeManager.playWelcomeSound(this, R.raw.welcome_sound)
        
        // ✅ INITIALISATION TTS AVEC CALLBACK
        TTSManager.initialize(this)
        
        // ✅ DÉLAI POUR LAISSER TTS S'INITIALISER PUIS WELCOME VOCAL
        android.os.Handler().postDelayed({
            handleWelcomeVoice()
        }, 2000) // 2 secondes pour TTS
        
        checkMicrophonePermission()
    }

    private fun handleWelcomeVoice() {
        // ✅ WELCOME VOCAL UNIQUEMENT APRÈS INITIALISATION TTS
        AppWelcomeManager.playWelcomeVoice(this)
    }

    private fun checkMicrophonePermission() {
        if (ContextCompat.checkSelfPermission(
                this,
                android.Manifest.permission.RECORD_AUDIO
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            onMicrophoneGranted()
        } else {
            audioPermissionLauncher.launch(android.Manifest.permission.RECORD_AUDIO)
        }
    }

    private fun onMicrophoneGranted() {
        Toast.makeText(this, "Microphone autorisé", Toast.LENGTH_LONG).show()
    }

    private fun onMicrophoneDenied() {
        Toast.makeText(this, "Microphone refusé", Toast.LENGTH_LONG).show()
    }
}
ACTIVITY

# Ajouter aussi un reset debug dans AppWelcomeManager
cat > app/src/main/java/com/magiccontrol/welcome/AppWelcomeManager.kt << 'WELCOME'
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
WELCOME

echo "✅ CORRECTION TIMING APPLIQUÉE!"
echo "📊 Changements:"
echo "   - ✅ Délai de 2 secondes après TTS.initialize()"
echo "   - ✅ Toast debug pour voir shouldShowWelcome"
echo "   - ✅ Séparation son toast et message vocal"
echo ""
echo "🚀 Push pour tester avec timing corrigé!"
