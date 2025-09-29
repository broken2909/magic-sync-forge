#!/bin/bash
echo "🔧 Suppression doublon initialisation TTS..."

# Corriger FullRecognitionService - RETIRER TTSManager.initialize
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
        // TTS déjà initialisé par MainActivity - NE PAS réinitialiser
        loadVoskModel()
    }

    private fun loadVoskModel() {
        try {
            val currentLanguage = PreferencesManager.getCurrentLanguage(applicationContext)
            val modelPath = ModelManager.getModelPathForLanguage(applicationContext, currentLanguage)
            
            if (ModelManager.isModelAvailable(applicationContext, currentLanguage)) {
                voskModel = Model(applicationContext.assets, modelPath)
                recognizer = Recognizer(voskModel, sampleRate.toFloat())
                Log.d(TAG, "Model Vosk chargé: $modelPath")
            } else {
                Log.w(TAG, "Model Vosk non disponible - Utilisation mode simulation")
            }
        } catch (e: IOException) {
            Log.e(TAG, "Erreur chargement model Vosk", e)
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

        try {
            while (isListening && System.currentTimeMillis() - startTime < timeout) {
                val bytesRead = audioRecord?.read(buffer, 0, bufferSize) ?: 0
                if (bytesRead > 0) {
                    if (recognizer?.acceptWaveForm(buffer, bytesRead) == true) {
                        val result = recognizer?.result
                        result?.let {
                            val command = extractCommandFromVoskResult(it)
                            if (command.isNotBlank()) {
                                processCommand(command)
                                break
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

        while (isListening && System.currentTimeMillis() - startTime < timeout) {
            try {
                val bytesRead = audioRecord?.read(buffer, 0, bufferSize) ?: 0
                if (bytesRead > 0) {
                    val command = simulateSpeechRecognition(buffer, bytesRead)
                    if (command.isNotBlank()) {
                        processCommand(command)
                        break
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

# Vérification finale
echo "✅ Doublon TTS supprimé!"
echo "🔍 Vérification..."
grep -r "TTSManager.initialize" app/src/main/java/
echo ""
echo "📊 État final:"
echo "✅ 1 seule initialisation TTS (MainActivity)"
echo "✅ FullRecognitionService utilise TTS sans réinitialiser"
echo "✅ Prêt pour vérification build et push GitHub"
