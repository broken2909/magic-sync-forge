#!/bin/bash
echo "🎤 WELCOME INTELLIGENT POUR MALVOYANTS"

# 1. Recréer WelcomeManager pour première ouverture seulement
mkdir -p app/src/main/java/com/magiccontrol/utils
cat > app/src/main/java/com/magiccontrol/utils/WelcomeManager.kt << 'WELCOME'
package com.magiccontrol.utils

import android.content.Context
import android.content.SharedPreferences
import java.util.Locale

object WelcomeManager {
    private const val PREFS_WELCOME = "welcome_prefs"
    private const val KEY_FIRST_LAUNCH = "first_launch"
    private const val KEY_WELCOME_SHOWN = "welcome_shown"

    fun isFirstLaunch(context: Context): Boolean {
        val prefs = context.getSharedPreferences(PREFS_WELCOME, Context.MODE_PRIVATE)
        return prefs.getBoolean(KEY_FIRST_LAUNCH, true)
    }

    fun shouldShowWelcome(context: Context): Boolean {
        val prefs = context.getSharedPreferences(PREFS_WELCOME, Context.MODE_PRIVATE)
        return !prefs.getBoolean(KEY_WELCOME_SHOWN, false)
    }

    fun markWelcomeShown(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_WELCOME, Context.MODE_PRIVATE)
        prefs.edit().putBoolean(KEY_WELCOME_SHOWN, true).apply()
    }

    fun markFirstLaunchComplete(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_WELCOME, Context.MODE_PRIVATE)
        prefs.edit().putBoolean(KEY_FIRST_LAUNCH, false).apply()
    }

    fun getWelcomeMessage(): String {
        val currentLocale = Locale.getDefault().language
        return when (currentLocale) {
            "fr" -> "Bienvenue dans votre assistant vocal MagicControl"
            "en" -> "Welcome to your MagicControl voice assistant"
            "es" -> "Bienvenido a su asistente de voz MagicControl"
            "de" -> "Willkommen bei Ihrem MagicControl-Sprachassistenten"
            "it" -> "Benvenuto nel tuo assistente vocale MagicControl"
            "pt" -> "Bem-vindo ao seu assistente de voz MagicControl"
            "ar" -> "مرحبًا بك في مساعدك الصوتي MagicControl"
            "ru" -> "Добро пожаловать в ваш голосовой помощник MagicControl"
            "zh" -> "欢迎使用您的 MagicControl 语音助手"
            "ja" -> "MagicControl音声アシスタントへようこそ"
            else -> "Welcome to your MagicControl voice assistant"
        }
    }
}
WELCOME

# 2. MainActivity avec logique intelligente
cat > app/src/main/java/com/magiccontrol/MainActivity.kt << 'ACTIVITY'
package com.magiccontrol

import android.content.Intent
import android.content.pm.PackageManager
import android.media.MediaPlayer
import android.os.Bundle
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.magiccontrol.tts.TTSManager
import com.magiccontrol.utils.WelcomeManager

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
        
        // ✅ WELCOME INTELLIGENT
        handleWelcomeLogic()
        checkMicrophonePermission()
    }

    private fun handleWelcomeLogic() {
        // ✅ SON TOAST TOUJOURS
        playToastSound()
        
        // ✅ WELCOME VOCAL UNE SEULE FOIS
        if (WelcomeManager.shouldShowWelcome(this)) {
            val welcomeMessage = WelcomeManager.getWelcomeMessage()
            TTSManager.speak(this, welcomeMessage)
            WelcomeManager.markWelcomeShown(this)
            WelcomeManager.markFirstLaunchComplete(this)
        }
    }

    private fun playToastSound() {
        try {
            val mediaPlayer = MediaPlayer.create(this, R.raw.welcome_sound)
            mediaPlayer?.setOnCompletionListener { mp ->
                mp.release()
            }
            mediaPlayer?.start()
        } catch (e: Exception) {
            // Son non critique
        }
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
        // ✅ "MagicControl activé" sera dit après détection "Magic"
        // Pour l'instant, rien ou message simple
        if (WelcomeManager.isFirstLaunch(this)) {
            TTSManager.speak(this, "Microphone autorisé")
        }
    }

    private fun onMicrophoneDenied() {
        Toast.makeText(this, "Microphone refusé", Toast.LENGTH_LONG).show()
    }
}
ACTIVITY

echo "✅ WELCOME INTELLIGENT CONFIGURÉ!"
echo "📊 Logique pour malvoyants:"
echo "   - ✅ Premier lancement: 'Bienvenue dans votre assistant vocal MagicControl'"
echo "   - ✅ Langue système détectée automatiquement"
echo "   - ✅ Une seule fois après installation"
echo "   - ✅ Son toast à chaque ouverture"
echo "   - ✅ 'MagicControl activé' réservé pour après détection mot-clé"
echo ""
echo "🎯 PARFAIT POUR LES MALVOYANTS!"
