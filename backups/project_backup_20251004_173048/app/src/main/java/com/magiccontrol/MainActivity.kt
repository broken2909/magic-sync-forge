package com.magiccontrol

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.media.MediaPlayer
import android.os.Bundle
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.magiccontrol.service.ModelDownloadService
import com.magiccontrol.service.WakeWordService
import com.magiccontrol.utils.FirstLaunchWelcome
import com.magiccontrol.ui.settings.SettingsActivity
import android.widget.Button

class MainActivity : AppCompatActivity() {

    private val requestPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        if (isGranted) {
            android.util.Log.d("MainActivity", "✅ Permission micro accordée - Démarrage services vocaux")
            startVoiceServices() 
        } else {
            android.util.Log.w("MainActivity", "❌ Permission microphone refusée")
        }
    }

    private val extractionReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val success = intent.getBooleanExtra("success", false)
            val message = intent.getStringExtra("message") ?: ""
            
            android.util.Log.d("MainActivity", "📨 Broadcast reçu: $success - $message")
            
            // Afficher le popup de confirmation
            showExtractionResult(success, message)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        android.util.Log.d("MainActivity", "🚀 Application démarrée")

        // Enregistrer le receiver pour les résultats d'extraction
        LocalBroadcastManager.getInstance(this)
            .registerReceiver(extractionReceiver, IntentFilter("EXTRACTION_COMPLETE"))

        // 1. Son welcome_sound à CHAQUE ouverture
        playWelcomeSound()
        
        // 2. Message BIENVENUE uniquement premier lancement
        FirstLaunchWelcome.playWelcomeIfFirstLaunch(this)
        
        // 3. Permission micro
        requestMicrophonePermission()
        
        // 4. Configuration bouton paramètres
        setupSettingsButton()
    }

    private fun playWelcomeSound() {
        try {
            val mediaPlayer = MediaPlayer.create(this, R.raw.welcome_sound)
            mediaPlayer?.setOnCompletionListener { it.release() }
            mediaPlayer?.start()
            android.util.Log.d("MainActivity", "🔊 Son welcome_sound joué")
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "❌ Erreur son welcome_sound", e)
        }
    }

    private fun requestMicrophonePermission() {
        when {
            ContextCompat.checkSelfPermission(
                this,
                android.Manifest.permission.RECORD_AUDIO
            ) == PackageManager.PERMISSION_GRANTED -> {
                android.util.Log.d("MainActivity", "✅ Permission micro déjà accordée")
                startVoiceServices()
            }
            else -> {
                android.util.Log.d("MainActivity", "📋 Demande permission micro")
                requestPermissionLauncher.launch(android.Manifest.permission.RECORD_AUDIO)
            }
        }
    }

    private fun startVoiceServices() {
        android.util.Log.d("MainActivity", "🔧 Démarrage services vocaux...")
        
        // 1. Démarrer l'extraction des modèles Vosk
        val extractIntent = Intent(this, ModelDownloadService::class.java)
        startService(extractIntent)
        android.util.Log.d("MainActivity", "📦 ModelDownloadService démarré (extraction Vosk)")
        
        // 2. Démarrer l'écoute vocale (mode simulation pour l'instant)
        val wakeIntent = Intent(this, WakeWordService::class.java)
        startService(wakeIntent)
        android.util.Log.d("MainActivity", "🎤 WakeWordService démarré (écoute simulation)")
        
        android.util.Log.d("MainActivity", "✅ Tous les services vocaux démarrés")
    }

    private fun showExtractionResult(success: Boolean, message: String) {
        runOnUiThread {
            AlertDialog.Builder(this)
                .setTitle(if (success) "✅ Configuration réussie" else "❌ Configuration échouée")
                .setMessage(message)
                .setPositiveButton("OK") { dialog, _ -> 
                    dialog.dismiss()
                    android.util.Log.d("MainActivity", "👤 Utilisateur a confirmé le popup")
                }
                .setCancelable(false)
                .show()
            
            android.util.Log.d("MainActivity", "📱 Popup affiché: $message")
        }
    }

    private fun setupSettingsButton() {
        try {
            val settingsButton = findViewById<Button>(R.id.settings_button)
            settingsButton.setOnClickListener {
                android.util.Log.d("MainActivity", "⚙️ Ouverture paramètres")
                val intent = Intent(this, SettingsActivity::class.java)
                startActivity(intent)
            }
            android.util.Log.d("MainActivity", "⚙️ Bouton paramètres configuré")
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Erreur configuration bouton paramètres", e)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // Désenregistrer le receiver
        LocalBroadcastManager.getInstance(this).unregisterReceiver(extractionReceiver)
        android.util.Log.d("MainActivity", "🛑 Application fermée")
    }
}
