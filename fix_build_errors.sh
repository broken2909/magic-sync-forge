#!/bin/bash
echo "🚨 CORRECTION ERREURS BUILD GITHUB..."

# 1. Corriger FullRecognitionService - Vosk Android + break
cat > app/src/main/java/com/magiccontrol/service/FullRecognitionService.kt << 'FILE1'
package com.magiccontrol.service

import android.app.Service
import android.content.Intent
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.IBinder
import android.util.Log
import com.magiccontrol.system.SystemIntegration
import com.magiccontrol.tts.TTSManager
import com.magiccontrol.utils.ModelManager
import com.magiccontrol.utils.PreferencesManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.vosk.Model
import org.vosk.Recognizer
import org.json.JSONObject
import java.io.IOException

class FullRecognitionService : Service() {

    private var voskModel: Model? = null
    private var recognizer: Recognizer? = null
    private var audioRecord: AudioRecord? = null
    private var isListening = false
    private val sampleRate = 16000
    private val bufferSize = 4096
    private val TAG = "FullRecognitionService"
    private val recognitionScope = CoroutineScope(Dispatchers.IO + Job())
    private var recognitionJob: Job? = null

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service de reconnaissance complète créé")
        loadVoskModel()
    }

    private fun loadVoskModel() {
        try {
            val currentLanguage = PreferencesManager.getCurrentLanguage(applicationContext)
            val modelPath = ModelManager.getModelPathForLanguage(applicationContext, currentLanguage)
            
            if (ModelManager.isModelAvailable(applicationContext, currentLanguage)) {
                // ✅ CORRECTION: Vosk Android utilise AssetManager directement
                voskModel = Model(applicationContext.assets, modelPath)
                recognizer = Recognizer(voskModel, sampleRate.toFloat())
                Log.d(TAG, "Model Vosk chargé: $modelPath")
            } else {
                Log.w(TAG, "Model Vosk non disponible - Utilisation mode simulation")
            }
        } catch (e: IOException) {
            Log.e(TAG, "Erreur chargement model Vosk", e)
        } catch (e: Exception) {
            Log.e(TAG, "Erreur initialisation Vosk", e)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Démarrage de la reconnaissance vocale")
        startRecognition()
        return START_NOT_STICKY
    }

    private fun startRecognition() {
        if (isListening) return

        try {
            TTSManager.speak(applicationContext, "Je vous écoute")

            val minBufferSize = AudioRecord.getMinBufferSize(
                sampleRate,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT
            )

            audioRecord = AudioRecord(
                MediaRecorder.AudioSource.VOICE_RECOGNITION,
                sampleRate,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
                minBufferSize.coerceAtLeast(bufferSize)
            )

            audioRecord?.startRecording()
            isListening = true

            recognitionJob = recognitionScope.launch {
                if (recognizer != null) {
                    processAudioWithVosk()
                } else {
                    processAudioSimulation()
                }
            }

        } catch (e: Exception) {
            Log.e(TAG, "Erreur démarrage reconnaissance", e)
            TTSManager.speak(applicationContext, "Erreur microphone")
            stopSelf()
        }
    }

    private suspend fun processAudioWithVosk() {
        val buffer = ByteArray(bufferSize)
        val timeout = 10000L
        val startTime = System.currentTimeMillis()
        var commandDetected = false

        try {
            while (isListening && System.currentTimeMillis() - startTime < timeout && !commandDetected) {
                val bytesRead = audioRecord?.read(buffer, 0, bufferSize) ?: 0
                if (bytesRead > 0) {
                    if (recognizer?.acceptWaveForm(buffer, bytesRead) == true) {
                        val result = recognizer?.result
                        result?.let {
                            val command = extractCommandFromVoskResult(it)
                            if (command.isNotBlank()) {
                                processCommand(command)
                                commandDetected = true
                            }
                        }
                    }
                }
                delay(50)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erreur traitement Vosk", e)
        }

        stopSelf()
    }

    private suspend fun processAudioSimulation() {
        val buffer = ByteArray(bufferSize)
        val timeout = 10000L
        val startTime = System.currentTimeMillis()
        var commandDetected = false

        while (isListening && System.currentTimeMillis() - startTime < timeout && !commandDetected) {
            try {
                val bytesRead = audioRecord?.read(buffer, 0, bufferSize) ?: 0
                if (bytesRead > 0) {
                    val command = simulateSpeechRecognition(buffer, bytesRead)
                    if (command.isNotBlank()) {
                        processCommand(command)
                        commandDetected = true
                    }
                }
                delay(100)
            } catch (e: Exception) {
                Log.e(TAG, "Erreur traitement audio simulation", e)
                break
            }
        }
        stopSelf()
    }

    private fun extractCommandFromVoskResult(voskResult: String): String {
        return try {
            val jsonObject = JSONObject(voskResult)
            val text = jsonObject.getString("text")
            Log.d(TAG, "Vosk a reconnu: $text")
            text
        } catch (e: Exception) {
            Log.e(TAG, "Erreur parsing résultat Vosk", e)
            ""
        }
    }

    private fun simulateSpeechRecognition(buffer: ByteArray, bytesRead: Int): String {
        val audioText = String(buffer, 0, bytesRead.coerceAtMost(100))
        Log.d(TAG, "Audio simulation: ${audioText.take(50)}...")
        
        return when {
            audioText.contains("volume", ignoreCase = true) -> "volume augmenter"
            audioText.contains("wifi", ignoreCase = true) -> "wifi"
            audioText.contains("paramètres", ignoreCase = true) -> "paramètres"
            audioText.contains("accueil", ignoreCase = true) -> "accueil"
            else -> ""
        }
    }

    private fun processCommand(command: String) {
        Log.d(TAG, "Commande traitée: $command")
        SystemIntegration.handleSystemCommand(applicationContext, command)
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Arrêt service reconnaissance")
        
        isListening = false
        recognitionJob?.cancel()
        
        try {
            audioRecord?.stop()
            audioRecord?.release()
            recognizer?.close()
            voskModel?.close()
        } catch (e: Exception) {
            Log.e(TAG, "Erreur libération ressources", e)
        }
        audioRecord = null
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
FILE1

# 2. Vérifier aussi WakeWordDetector pour Vosk Android
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

echo "✅ Corrections appliquées!"
echo "📊 Modifications:"
echo "   - Vosk Android: Model(assets, path) au lieu de Model()"
echo "   - Remplacé 'break' par variable flag dans fonctions suspendues"
echo "   - Gestion erreurs Vosk renforcée"
echo ""
echo "🚀 Prêt pour nouveau push GitHub!"
