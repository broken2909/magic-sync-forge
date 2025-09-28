package com.magiccontrol.recognizer

import android.content.Context
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Process
import android.util.Log
import com.magiccontrol.utils.PreferencesManager
import java.util.Locale

class WakeWordDetector(private val context: Context) {

    private var audioRecord: AudioRecord? = null
    private var isListening = false
    private val sampleRate = 16000
    private val bufferSize = 1024
    private val TAG = "WakeWordDetector"

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

            Log.d(TAG, "Détection démarrée")

        } catch (e: Exception) {
            Log.e(TAG, "Erreur démarrage écoute", e)
            stopListening()
        }
    }

    private fun processAudioSimulation(buffer: ByteArray, bytesRead: Int) {
        val keyword = PreferencesManager.getActivationKeyword(context)
        
        // Simulation avec seuil élevé pour stabilité
        val energy = buffer.take(bytesRead).map { it.toInt() }.sumOf { kotlin.math.abs(it) }
        if (energy > 100000) {
            val currentLanguage = PreferencesManager.getCurrentLanguage(context)
            val languageKeyword = if (currentLanguage == "fr") "magic" else "magic"
            
            if (languageKeyword.contains(keyword, ignoreCase = true)) {
                Log.d(TAG, "Mot d'activation détecté: $keyword")
                onWakeWordDetected?.invoke()
            }
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
}
