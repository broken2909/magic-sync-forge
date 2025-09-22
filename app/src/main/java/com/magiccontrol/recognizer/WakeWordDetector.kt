package com.magiccontrol.recognizer

import android.content.Context
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import android.os.Looper

class WakeWordDetector(private val context: Context) {
    
    private var audioRecord: AudioRecord? = null
    private var isListening = false
    
    fun startListening() {
        if (isListening) return
        
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
            
            // Simulation de détection pour le moment
            Handler(Looper.getMainLooper()).postDelayed({
                onWakeWordDetected()
            }, 3000)
            
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    
    private fun onWakeWordDetected() {
        // Lancer la reconnaissance complète
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
