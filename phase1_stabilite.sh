#!/bin/bash
echo "🎯 PHASE 1 - STABILITÉ MAXIMUM"

# Corriger MainActivity pour Phase 1 uniquement
cat > app/src/main/java/com/magiccontrol/MainActivity.kt << 'FILE1'
package com.magiccontrol

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.magiccontrol.databinding.ActivityMainBinding
import com.magiccontrol.utils.WelcomeManager

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
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
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setupToolbar()
        setupButtons()
        
        // ✅ PHASE 1 UNIQUEMENT - STABILITÉ MAXIMUM
        showWelcomeToast()
        checkMicrophonePermission()
    }

    private fun setupToolbar() {
        setSupportActionBar(binding.toolbar)
    }

    private fun setupButtons() {
        binding.voiceButton.setOnClickListener {
            Toast.makeText(this, "Fonction vocale - Phase 2", Toast.LENGTH_SHORT).show()
        }

        binding.settingsButton.setOnClickListener {
            Toast.makeText(this, "Paramètres - Phase 2", Toast.LENGTH_SHORT).show()
        }
    }

    private fun showWelcomeToast() {
        if (WelcomeManager.shouldShowWelcome(this)) {
            val welcomeMessage = WelcomeManager.getWelcomeMessage()
            Toast.makeText(this, welcomeMessage, Toast.LENGTH_LONG).show()
            WelcomeManager.markWelcomeShown(this)
        } else {
            Toast.makeText(this, "MagicControl", Toast.LENGTH_LONG).show()
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
        Toast.makeText(this, "✅ Microphone autorisé - Prêt pour Phase 2", Toast.LENGTH_LONG).show()
        // ✅ PHASE 2: TTSManager.initialize() + services
    }

    private fun onMicrophoneDenied() {
        Toast.makeText(this, "❌ Microphone refusé - Mode limité", Toast.LENGTH_LONG).show()
    }
}
FILE1

echo "✅ PHASE 1 APPLIQUÉE!"
echo "📊 Fonctionnalités activées:"
echo "   - ✅ Toast + Welcome messages"
echo "   - ✅ Demande permission microphone" 
echo "   - ✅ Interface basique stable"
echo "   - ❌ Aucun service complexe"
echo "   - ❌ Aucun TTS (risque crash)"
echo ""
echo "🚀 Testez l'application - Elle ne devrait PLUS crash!"
