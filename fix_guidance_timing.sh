#!/bin/bash
echo "🔧 CORRECTION TIMING MESSAGE GUIDANCE"

# Modifier uniquement la séquence dans onCreate()
cat > app/src/main/java/com/magiccontrol/MainActivity.kt << 'FIXED_TIMING'
package com.magiccontrol

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.appcompat.app.AppCompatActivity
import com.magiccontrol.databinding.ActivityMainBinding
import com.magiccontrol.service.WakeWordService
import com.magiccontrol.tts.TTSManager
import com.magiccontrol.utils.FirstLaunchWelcome
import com.magiccontrol.utils.PreferencesManager

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setupToolbar()
        setupButtons()
        
        // Message bienvenue premier lancement
        FirstLaunchWelcome.playWelcomeIfFirstLaunch(this)
        
        // MESSAGE GUIDANCE ISOLÉ - IMMÉDIAT après bienvenue
        playGuidanceMessage()
        
        // Démarrer service vocal APRÈS délai de 3 secondes
        handler.postDelayed({
            startWakeWordService()
        }, 3000) // Délai pour laisser le message guidance terminer
    }

    private fun setupToolbar() {
        setSupportActionBar(binding.toolbar)
    }

    private fun setupButtons() {
        binding.voiceButton.setOnClickListener {
            // TODO: Implement direct voice command
        }

        binding.settingsButton.setOnClickListener {
            // TODO: Open settings activity
        }
    }

    private fun startWakeWordService() {
        val intent = Intent(this, WakeWordService::class.java)
        startService(intent)
    }
    
    // MESSAGE GUIDANCE COMPLÈTEMENT ISOLÉ
    private fun playGuidanceMessage() {
        try {
            val currentLanguage = PreferencesManager.getCurrentLanguage(this)
            val guidanceMessage = if (currentLanguage == "fr") {
                "MagicControl nécessite une activation manuelle dans les paramètres d'accessibilité pour contrôler votre appareil. Nous recommandons une assistance pour cette étape."
            } else {
                "MagicControl requires manual activation in accessibility settings to control your device. We recommend assistance for this step."
            }
            
            TTSManager.speak(this, guidanceMessage)
            println("🔊 Message guidance isolé joué: $guidanceMessage")
            
        } catch (e: Exception) {
            println("⚠️ Erreur message guidance isolé: ${e.message}")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // Nettoyer le handler
        handler.removeCallbacksAndMessages(null)
    }
}
FIXED_TIMING

echo ""
echo "✅ TIMING CORRIGÉ"
echo "📊 Nouvelle séquence :"
echo "   1. Son welcome + Message bienvenue"
echo "   2. Message guidance accessibilité (IMMÉDIAT)"
echo "   3. Délai 3 secondes"
echo "   4. Démarrage service vocal"
echo ""
echo "🔍 VÉRIFICATION SÉQUENCE :"
grep -A 8 "FirstLaunchWelcome.playWelcomeIfFirstLaunch" app/src/main/java/com/magiccontrol/MainActivity.kt
