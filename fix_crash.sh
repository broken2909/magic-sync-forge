#!/bin/bash
echo "🔧 Correction du crash d'ouverture..."

# 1. Corriger MagicControlApplication - RETIRER l'initialisation TTS
cat > app/src/main/java/com/magiccontrol/MagicControlApplication.kt << 'FILE1'
package com.magiccontrol

import android.app.Application

class MagicControlApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Initialisation future: autres composants globaux
    }
}
FILE1

# 2. Corriger WakeWordDetector - AJOUTER vérification permission AVANT AudioRecord
cat > app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt << 'FILE2'
package com.magiccontrol.recognizer

import android.content.Context
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Process
import android.util.Log
import androidx.core.content.ContextCompat
import com.magiccontrol.utils.PreferencesManager

class WakeWordDetector(private val context: Context) {
    
    private var audioRecord: AudioRecord? = null
    private var isListening = false
    private val sampleRate = 16000
    private val bufferSize = 1024
    private val TAG = "WakeWordDetector"
    
    var onWakeWordDetected: (() -> Unit)? = null
    
    private fun hasMicrophonePermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            context,
            android.Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
    }
    
    fun startListening(): Boolean {
        if (isListening) return true
        
        // ✅ VÉRIFICATION CRITIQUE PERMISSION AVANT TOUTE INITIALISATION AUDIO
        if (!hasMicrophonePermission()) {
            Log.w(TAG, "Permission microphone non accordée - Détection impossible")
            return false
        }
        
        try {
            val minBufferSize = AudioRecord.getMinBufferSize(
                sampleRate,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT
            )
            
            // ✅ VÉRIFICATION SUPPLÉMENTAIRE DE LA CONFIGURATION AUDIO
            if (minBufferSize == AudioRecord.ERROR || minBufferSize == AudioRecord.ERROR_BAD_VALUE) {
                Log.e(TAG, "Configuration audio invalide")
                return false
            }
            
            audioRecord = AudioRecord(
                MediaRecorder.AudioSource.VOICE_RECOGNITION,
                sampleRate,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
                minBufferSize.coerceAtLeast(bufferSize)
            )
            
            // ✅ VÉRIFICATION ÉTAT AudioRecord AVANT démarrage
            if (audioRecord?.state != AudioRecord.STATE_INITIALIZED) {
                Log.e(TAG, "AudioRecord non initialisé correctement")
                audioRecord?.release()
                audioRecord = null
                return false
            }
            
            audioRecord?.startRecording()
            isListening = true
            
            Thread {
                Process.setThreadPriority(Process.THREAD_PRIORITY_BACKGROUND)
                val buffer = ByteArray(bufferSize)
                
                while (isListening) {
                    val bytesRead = audioRecord?.read(buffer, 0, bufferSize) ?: 0
                    if (bytesRead > 0) {
                        processAudioSimulation(buffer, bytesRead)
                    }
                    Thread.sleep(50)
                }
            }.start()
            
            Log.d(TAG, "Détection démarrée avec succès")
            return true
            
        } catch (e: Exception) {
            Log.e(TAG, "Erreur démarrage écoute", e)
            stopListening()
            return false
        }
    }
    
    private fun processAudioSimulation(buffer: ByteArray, bytesRead: Int) {
        val keyword = PreferencesManager.getActivationKeyword(context)
        val audioText = String(buffer, 0, bytesRead.coerceAtMost(100))
        
        if (audioText.contains(keyword, ignoreCase = true)) {
            Log.d(TAG, "Mot d'activation détecté: $keyword")
            onWakeWordDetected?.invoke()
        }
    }
    
    fun stopListening() {
        isListening = false
        try {
            audioRecord?.stop()
            audioRecord?.release()
        } catch (e: Exception) {
            Log.e(TAG, "Erreur arrêt écoute", e)
        }
        audioRecord = null
        Log.d(TAG, "Détection arrêtée")
    }
    
    fun isListening(): Boolean = isListening
    
    fun isSystemFunctional(): Boolean {
        return try {
            val minBufferSize = AudioRecord.getMinBufferSize(
                sampleRate,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT
            )
            minBufferSize > 0 && hasMicrophonePermission()
        } catch (e: Exception) {
            false
        }
    }
}
FILE2

# 3. Corriger MainActivity - RETARDER le démarrage du service
cat > app/src/main/java/com/magiccontrol/MainActivity.kt << 'FILE3'
package com.magiccontrol

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.magiccontrol.service.WakeWordService
import com.magiccontrol.utils.WelcomeManager
import com.magiccontrol.tts.TTSManager

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

        setupToolbar()
        setupButtons()
        showWelcomeToast()
        checkMicrophonePermission()
    }

    private fun setupToolbar() {
        val toolbar = findViewById<androidx.appcompat.widget.Toolbar>(R.id.toolbar)
        setSupportActionBar(toolbar)
    }

    private fun setupButtons() {
        val voiceButton = findViewById<android.widget.ImageButton>(R.id.voice_button)
        val settingsButton = findViewById<android.widget.Button>(R.id.settings_button)

        voiceButton.setOnClickListener {
            Toast.makeText(this, "Commande vocale directe", Toast.LENGTH_SHORT).show()
        }

        settingsButton.setOnClickListener {
            Toast.makeText(this, "Paramètres", Toast.LENGTH_SHORT).show()
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
        // ✅ INITIALISATION TTS UNIQUEMENT ICI, APRÈS PERMISSION
        TTSManager.initialize(this)
        
        if (WelcomeManager.shouldShowWelcome(this)) {
            val welcomeMessage = WelcomeManager.getWelcomeMessage()
            TTSManager.speak(this, welcomeMessage)
        } else {
            TTSManager.speak(this, "MagicControl activé")
        }

        // ✅ DÉMARRAGE SERVICE UNIQUEMENT APRÈS INITIALISATION TTS
        android.os.Handler().postDelayed({
            startWakeWordService()
        }, 3000) // Délai augmenté pour stabilité
    }

    private fun onMicrophoneDenied() {
        Toast.makeText(this, "Microphone refusé - Mode limité", Toast.LENGTH_LONG).show()
        // Services non démarrés intentionnellement
    }

    private fun startWakeWordService() {
        try {
            val intent = Intent(this, WakeWordService::class.java)
            startService(intent)
            Toast.makeText(this, "Service vocal activé", Toast.LENGTH_SHORT).show()
        } catch (e: Exception) {
            Toast.makeText(this, "Erreur service vocal", Toast.LENGTH_SHORT).show()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
    }
}
FILE3

echo "✅ Corrections appliquées!"
echo "📊 Changements:"
echo "   - Retiré TTS de MagicControlApplication"
echo "   - Renforcé vérifications permissions dans WakeWordDetector"
echo "   - Délai augmenté pour stabilité"
echo ""
echo "🚀 Testez maintenant l'application"
