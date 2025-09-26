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
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class FullRecognitionService : Service() {

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
        TTSManager.initialize(applicationContext)
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
                processAudio()
            }

        } catch (e: Exception) {
            Log.e(TAG, "Erreur lors du démarrage de la reconnaissance", e)
            TTSManager.speak(applicationContext, "Erreur microphone")
            stopSelf()
        }
    }

    private suspend fun processAudio() {
        val buffer = ByteArray(bufferSize)
        val timeout = 10000L // 10 secondes timeout
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
                delay(100) // Réduire la charge CPU
            } catch (e: Exception) {
                Log.e(TAG, "Erreur lors du traitement audio", e)
                break
            }
        }

        stopSelf()
    }

    private fun simulateSpeechRecognition(buffer: ByteArray, bytesRead: Int): String {
        // Simulation simple - dans une vraie implémentation, utiliser Vosk
        val energy = buffer.take(bytesRead).map { it.toInt() }.sumOf { kotlin.math.abs(it) }
        
        return when {
            energy > 80000 -> "augmenter le volume"
            energy > 60000 -> "baisser le volume"
            energy > 40000 -> "activer wifi"
            energy > 20000 -> "ouvrir paramètres"
            else -> ""
        }
    }

    private fun processCommand(command: String) {
        Log.d(TAG, "Commande reconnue: $command")
        SystemIntegration.handleSystemCommand(applicationContext, command)
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Arrêt du service de reconnaissance")
        isListening = false
        recognitionJob?.cancel()
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
    }

    override fun onBind(intent: Intent?): IBinder? = null
}