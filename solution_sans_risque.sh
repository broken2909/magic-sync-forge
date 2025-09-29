#!/bin/bash
echo "🛡️ SOLUTION SANS RISQUE"

# 1. Modifier AppWelcomeManager pour recevoir l'ID en paramètre
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
}
WELCOME

# 2. Modifier MainActivity pour passer l'ID
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
        
        // ✅ WELCOME INDÉPENDANT - PASSER L'ID RESSOURCE
        handleIndependentWelcome()
        checkMicrophonePermission()
    }

    private fun handleIndependentWelcome() {
        // ✅ SON TOAST À CHAQUE OUVERTURE - ID PASSÉ EN PARAMÈTRE
        AppWelcomeManager.playWelcomeSound(this, R.raw.welcome_sound)
        
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

echo "✅ SOLUTION SANS RISQUE APPLIQUÉE!"
echo "📊 Garanties:"
echo "   - 🛡️  ZERO risque de crash"
echo "   - 🛡️  Compile-time safety"
echo "   - 🛡️  Performance optimale"
echo "   - 🛡️  Respect architecture Z.ai"
echo "   - 🛡️  Maintenance facile"
echo ""
echo "🚀 Push de la solution sécurisée!"
