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
import com.magiccontrol.utils.ModelManager
import org.vosk.Model
import org.vosk.Recognizer
import org.json.JSONObject
import java.io.File

class WakeWordDetector(private val context: Context) {

    private var audioRecord: AudioRecord? = null
    private var isListening = false
    private val sampleRate = 16000
    private val bufferSize = 1024
    private val TAG = "WakeWordDetector"
    
    // VOSK Components
    private var voskModel: Model? = null
    private var voskRecognizer: Recognizer? = null

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

        // Initialize VOSK model
        if (!initializeVoskModel()) {
            Log.e(TAG, "Erreur initialisation modèle VOSK")
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
                        processAudioWithVosk(buffer, bytesRead)
                    }
                    Thread.sleep(50)
                }
            }.start()

            Log.d(TAG, "Détection VOSK démarrée avec succès")
            return true

        } catch (e: Exception) {
            Log.e(TAG, "Erreur démarrage écoute", e)
            stopListening()
            return false
        }
    }

    private fun initializeVoskModel(): Boolean {
        try {
            // Get current language from preferences
            val currentLanguage = PreferencesManager.getCurrentLanguage(context)
            val modelPath = ModelManager.getModelPathForLanguage(context, currentLanguage)
            
            // Check if model is available
            if (!ModelManager.isModelAvailable(context, currentLanguage)) {
                Log.e(TAG, "Modèle VOSK non disponible pour langue: $currentLanguage")
                return false
            }
            
            // Get absolute model path
            val absoluteModelPath = File(context.filesDir, "models/vosk-model-small-$currentLanguage-0.22").absolutePath
            Log.d(TAG, "Chargement modèle VOSK: $absoluteModelPath")
            
            if (!File(absoluteModelPath).exists()) {
                Log.e(TAG, "Chemin modèle VOSK inexistant: $absoluteModelPath")
                return false
            }
            
            // Initialize VOSK model and recognizer
            voskModel = Model(absoluteModelPath)
            voskRecognizer = Recognizer(voskModel, sampleRate.toFloat())
            
            Log.d(TAG, "Modèle VOSK initialisé avec succès")
            return true
            
        } catch (e: Exception) {
            Log.e(TAG, "Erreur initialisation VOSK", e)
            voskModel?.close()
            voskModel = null
            voskRecognizer = null
            return false
        }
    }

    private fun processAudioWithVosk(buffer: ByteArray, bytesRead: Int) {
        try {
            val recognizer = voskRecognizer ?: return
            
            if (recognizer.acceptWaveForm(buffer, bytesRead)) {
                val result = recognizer.result
                processVoskResult(result)
            } else {
                val partialResult = recognizer.partialResult
                processVoskPartial(partialResult)
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Erreur traitement audio VOSK", e)
        }
    }
    
    private fun processVoskResult(result: String) {
        try {
            val json = JSONObject(result)
            val text = json.optString("text", "").trim()
            
            if (text.isNotEmpty()) {
                Log.d(TAG, "VOSK résultat final: '$text'")
                checkForWakeWord(text)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erreur parsing résultat VOSK", e)
        }
    }
    
    private fun processVoskPartial(partialResult: String) {
        try {
            val json = JSONObject(partialResult)
            val partial = json.optString("partial", "").trim()
            
            if (partial.isNotEmpty()) {
                Log.d(TAG, "VOSK partiel: '$partial'")
                checkForWakeWord(partial)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erreur parsing partiel VOSK", e)
        }
    }
    
    private fun checkForWakeWord(text: String) {
        val keyword = PreferencesManager.getActivationKeyword(context).lowercase()
        val normalizedText = text.lowercase()
        
        if (normalizedText.contains(keyword)) {
            Log.d(TAG, "🎯 Mot d'activation VOSK détecté: '$keyword' dans '$text'")
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
        
        // Cleanup VOSK resources
        try {
            voskRecognizer = null
            voskModel?.close()
            voskModel = null
        } catch (e: Exception) {
            Log.e(TAG, "Erreur nettoyage VOSK", e)
        }
        
        Log.d(TAG, "Détection VOSK arrêtée")
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
