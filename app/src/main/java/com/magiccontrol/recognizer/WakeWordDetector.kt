package com.magiccontrol.recognizer

import android.content.Context
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Process
import android.util.Log
import com.magiccontrol.utils.ModelManager
import com.magiccontrol.utils.PreferencesManager
import org.vosk.Model
import org.vosk.Recognizer
import java.io.File
import java.io.IOException

class WakeWordDetector(private val context: Context) {

    private var voskModel: Model? = null
    private var recognizer: Recognizer? = null
    private var audioRecord: AudioRecord? = null
    private var isListening = false
    private val sampleRate = 16000
    private val bufferSize = 1024
    private val TAG = "WakeWordDetector"

    var onWakeWordDetected: (() -> Unit)? = null

    init {
        loadVoskModel()
    }

    private fun loadVoskModel() {
        try {
            val currentLanguage = PreferencesManager.getCurrentLanguage(context)
            val modelPath = ModelManager.getModelPathForLanguage(context, currentLanguage)
            
            if (ModelManager.isModelAvailable(context, currentLanguage)) {
                // SOLUTION: Copier assets vers fichier temporaire puis charger
                val tempModelDir = copyAssetsModelToTemp(modelPath)
                voskModel = Model(File(tempModelDir).absolutePath)
                recognizer = Recognizer(voskModel, sampleRate.toFloat())
                Log.d(TAG, "Model Vosk chargé depuis temp: $tempModelDir")
            } else {
                Log.w(TAG, "Model non disponible: $modelPath - Utilisation mode simulation")
            }
        } catch (e: IOException) {
            Log.e(TAG, "Erreur chargement model Vosk", e)
        } catch (e: Exception) {
            Log.e(TAG, "Erreur initialisation Vosk", e)
        }
    }

    private fun copyAssetsModelToTemp(modelPath: String): String {
        val tempDir = File(context.cacheDir, "vosk_models")
        if (!tempDir.exists()) tempDir.mkdirs()
        
        // Pour l'instant on retourne un chemin vide - À COMPLÉTER
        Log.d(TAG, "Copie assets à implémenter pour: $modelPath")
        return ""
    }

    fun startListening() {
        if (isListening) return

        try {
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

            Thread {
                Process.setThreadPriority(Process.THREAD_PRIORITY_BACKGROUND)
                val buffer = ByteArray(bufferSize)

                while (isListening) {
                    val bytesRead = audioRecord?.read(buffer, 0, bufferSize) ?: 0
                    if (bytesRead > 0) {
                        if (recognizer != null && voskModel != null) {
                            processAudioWithVosk(buffer, bytesRead)
                        } else {
                            processAudioSimulation(buffer, bytesRead)
                        }
                    }
                    Thread.sleep(50)
                }
            }.start()

            Log.d(TAG, "Détection Vosk démarrée")

        } catch (e: Exception) {
            Log.e(TAG, "Erreur démarrage écoute Vosk", e)
            stopListening()
        }
    }

    private fun processAudioWithVosk(buffer: ByteArray, bytesRead: Int) {
        try {
            if (recognizer?.acceptWaveForm(buffer, bytesRead) == true) {
                val result = recognizer?.result
                result?.let {
                    if (containsActivationKeyword(it)) {
                        Log.d(TAG, "Mot d'activation détecté par Vosk")
                        onWakeWordDetected?.invoke()
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erreur traitement Vosk", e)
        }
    }

    private fun processAudioSimulation(buffer: ByteArray, bytesRead: Int) {
        val keyword = PreferencesManager.getActivationKeyword(context)
        val audioText = String(buffer, 0, bytesRead.coerceAtMost(100))
        
        if (audioText.contains(keyword, ignoreCase = true)) {
            Log.d(TAG, "Mot d'activation détecté (simulation): $keyword")
            onWakeWordDetected?.invoke()
        }
    }

    private fun containsActivationKeyword(voskResult: String): Boolean {
        val keyword = PreferencesManager.getActivationKeyword(context)
        return voskResult.contains(keyword, ignoreCase = true)
    }

    fun stopListening() {
        isListening = false
        try {
            audioRecord?.stop()
            audioRecord?.release()
            recognizer?.close()
        } catch (e: Exception) {
            Log.e(TAG, "Erreur arrêt écoute Vosk", e)
        }
        audioRecord = null
        Log.d(TAG, "Détection Vosk arrêtée")
    }

    fun isListening(): Boolean = isListening
}
