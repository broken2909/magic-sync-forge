package com.magiccontrol.recognizer

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import android.os.Looper
import androidx.core.content.ContextCompat

class WakeWordDetector(private val context: Context) {

    private var audioRecord: AudioRecord? = null
    private var isListening = false
    private val handler = Handler(Looper.getMainLooper())
    private var listeningRunnable: Runnable? = null

    fun startListening() {
        if (isListening) return

        if (ContextCompat.checkSelfPermission(context, android.Manifest.permission.RECORD_AUDIO) 
            != PackageManager.PERMISSION_GRANTED) {
            return
        }

        isListening = true
        startOptimizedListening()
    }

    private fun startOptimizedListening() {
        listeningRunnable = object : Runnable {
            override fun run() {
                if (!isListening) return
                
                try {
                    // Écoute par cycles courts pour économiser la batterie
                    listenForWakeWordCycle()
                    
                    // Planifier le prochain cycle après une pause
                    handler.postDelayed(this, 2000) // Pause de 2 secondes entre les cycles
                    
                } catch (e: Exception) {
                    e.printStackTrace()
                    // En cas d'erreur, réessayer après un délai
                    handler.postDelayed(this, 5000)
                }
            }
        }
        
        handler.post(listeningRunnable!!)
    }

    private fun listenForWakeWordCycle() {
        // Cycle d'écoute court (1 seconde) pour détecter le mot d'éveil
        try {
            audioRecord = AudioRecord(
                MediaRecorder.AudioSource.MIC,
                16000,
                android.media.AudioFormat.CHANNEL_IN_MONO,
                android.media.AudioFormat.ENCODING_PCM_16BIT,
                16000 // Buffer pour 1 seconde d'audio
            )

            audioRecord?.startRecording()
            
            // Simuler la détection pour le moment
            // À REMPLACER par la vraie détection du mot "magic"
            val audioBuffer = ShortArray(16000)
            audioRecord?.read(audioBuffer, 0, audioBuffer.size)
            
            // ICI: Implémenter la détection du mot d'éveil
            // Pour l'instant, simulation toutes les 10 secondes
            if (System.currentTimeMillis() % 10000 < 100) {
                onWakeWordDetected()
            }
            
        } finally {
            // Toujours libérer les ressources après chaque cycle
            audioRecord?.stop()
            audioRecord?.release()
            audioRecord = null
        }
    }

    private fun onWakeWordDetected() {
        val intent = Intent(context, com.magiccontrol.service.FullRecognitionService::class.java)
        context.startService(intent)
    }

    fun stopListening() {
        isListening = false
        listeningRunnable?.let { handler.removeCallbacks(it) }
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
    }
}
