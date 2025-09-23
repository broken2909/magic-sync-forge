package com.magiccontrol.recognizer

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioRecord
import android.media.MediaRecorder
import androidx.core.content.ContextCompat

class WakeWordDetector(private val context: Context) {

    private var audioRecord: AudioRecord? = null
    private var isListening = false

    fun startListening() {
        if (isListening) return

        if (ContextCompat.checkSelfPermission(context, android.Manifest.permission.RECORD_AUDIO) 
            != PackageManager.PERMISSION_GRANTED) {
            return
        }

        try {
            audioRecord = AudioRecord(
                MediaRecorder.AudioSource.MIC,
                16000,
                android.media.AudioFormat.CHANNEL_IN_MONO,
                android.media.AudioFormat.ENCODING_PCM_16BIT,
                1024
            )

            audioRecord?.startRecording()
            isListening = true

            // À IMPLÉMENTER: vraie détection du mot d'éveil "magic"

        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun onWakeWordDetected() {
        val intent = Intent(context, com.magiccontrol.service.FullRecognitionService::class.java)
        context.startService(intent)
    }

    fun stopListening() {
        isListening = false
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
    }
}
