#!/bin/bash
echo "🔧 CORRECTION MainActivity SANS databinding"

# Version simplifiée sans databinding
cat > app/src/main/java/com/magiccontrol/MainActivity.kt << 'FILE1'
package com.magiccontrol

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
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

        // ✅ PHASE 1 UNIQUEMENT - STABILITÉ MAXIMUM
        showWelcomeToast()
        checkMicrophonePermission()
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
    }

    private fun onMicrophoneDenied() {
        Toast.makeText(this, "❌ Microphone refusé - Mode limité", Toast.LENGTH_LONG).show()
    }
}
FILE1

echo "✅ CORRECTION APPLIQUÉE!"
echo "📊 MainActivity maintenant:"
echo "   - ✅ Sans databinding (findViewById implicite)"
echo "   - ✅ Toast + Welcome + Permission micro"
echo "   - ✅ 100% compatible avec le layout existant"
echo ""
echo "🚀 Nouveau push GitHub!"
