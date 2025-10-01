#!/bin/bash
echo "🔧 AJOUT MESSAGE GUIDANCE ISOLÉ DANS MAINACTIVITY"

# Modifier MainActivity pour ajouter le message guidance isolé
cat > app/src/main/java/com/magiccontrol/MainActivity.kt << 'MAIN_WITH_GUIDANCE'
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
        
        // Démarrer service après autorisation micro
        startWakeWordService()
        
        // MESSAGE GUIDANCE ISOLÉ - 5 secondes après le démarrage
        handler.postDelayed({
            playGuidanceMessage()
        }, 5000) // Délai long pour être sûr que tout est initialisé
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
MAIN_WITH_GUIDANCE

echo ""
echo "✅ MESSAGE GUIDANCE ISOLÉ AJOUTÉ"
echo "📊 Caractéristiques :"
echo "   • Délai de 5 secondes après démarrage"
echo "   • Handler séparé et indépendant"
echo "   • Aucune liaison avec autres services"
echo "   • Gestion d'erreur intégrée"
echo ""
echo "🔍 VÉRIFICATION :"
grep -A 10 "MESSAGE GUIDANCE COMPLÈTEMENT ISOLÉ" app/src/main/java/com/magiccontrol/MainActivity.kt
