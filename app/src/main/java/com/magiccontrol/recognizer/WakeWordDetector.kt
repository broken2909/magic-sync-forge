package com.magiccontrol.recognizer

import android.content.Context
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.util.Log
import com.magiccontrol.utils.KeywordUtils
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class WakeWordDetector(private val context: Context) {

    private var audioRecord: AudioRecord? = null
    private var isListening = false
    private val sampleRate = 16000
    private val bufferSize = 4096
    private val TAG = "WakeWordDetector"
    private val detectionScope = CoroutineScope(Dispatchers.IO + Job())
    private var detectionJob: Job? = null

    var onWakeWordDetected: (() -> Unit)? = null

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

            detectionJob = detectionScope.launch {
                processAudio()
            }

            Log.d(TAG, "Détection du mot d'activation démarrée")

        } catch (e: Exception) {
            Log.e(TAG, "Erreur lors du démarrage de la détection", e)
        }
    }

    private suspend fun processAudio() {
        val buffer = ByteArray(bufferSize)

        while (isListening) {
            try {
                val bytesRead = audioRecord?.read(buffer, 0, bufferSize) ?: 0
                if (bytesRead > 0) {
                    val audioText = simulateWakeWordDetection(buffer, bytesRead)
                    if (KeywordUtils.containsActivationKeyword(context, audioText)) {
                        Log.d(TAG, "Mot d'activation détecté: $audioText")
                        onWakeWordDetected?.invoke()
                        break
                    }
                }
                delay(100)
            } catch (e: Exception) {
                Log.e(TAG, "Erreur lors du traitement audio", e)
                break
            }
        }
    }

    private fun simulateWakeWordDetection(buffer: ByteArray, bytesRead: Int): String {
        // Simulation simple - dans une vraie implémentation, utiliser Vosk ou Pocketsphinx
        val energy = buffer.take(bytesRead).map { it.toInt() }.sumOf { kotlin.math.abs(it) }
        
        return if (energy > 50000) { // Seuil arbitraire pour simulation
            "magic" // Retourne le mot d'activation par défaut
        } else {
            ""
        }
    }

    fun stopListening() {
        isListening = false
        detectionJob?.cancel()
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
        Log.d(TAG, "Détection du mot d'activation arrêtée")
    }
}