#!/bin/bash
echo "🚀 CRÉATION FONCTION WELCOME INDÉPENDANTE"

# 1. Créer le manager welcome indépendant
mkdir -p app/src/main/java/com/magiccontrol/welcome
cat > app/src/main/java/com/magiccontrol/welcome/AppWelcomeManager.kt << 'WELCOME'
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
WELCOME

# 2. Intégrer dans MainActivity
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

        // ✅ INITIALISATION TTS
        TTSManager.initialize(this)
        
        // ✅ WELCOME INDÉPENDANT
        handleIndependentWelcome()
        checkMicrophonePermission()
    }

    private fun handleIndependentWelcome() {
        // ✅ SON TOAST À CHAQUE OUVERTURE
        AppWelcomeManager.playWelcomeSound(this)
        
        // ✅ MESSAGE VOCAL PREMIÈRE FOIS SEULEMENT
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

echo "✅ FONCTION WELCOME INDÉPENDANTE CRÉÉE!"
echo "📊 Architecture:"
echo "   - ✅ AppWelcomeManager dans package séparé"
echo "   - ✅ Zéro dépendance Vosk/reconnaissance"
echo "   - ✅ Son toast à chaque ouverture"
echo "   - ✅ Message vocal première fois seulement"
echo "   - ✅ TTS Android gère langues automatiquement"
echo "   - ✅ SharedPreferences pour état"
echo ""
echo "🚀 Push pour tester la fonction indépendante!"
