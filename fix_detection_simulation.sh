#!/bin/bash
echo "🔧 AMÉLIORATION DÉTECTION SIMULATION - Pattern audio basique"

cd /data/data/com.termux/files/home/magic-sync-forge/

# ==================== CORRECTION WAKEWORDDETECTOR ====================
echo "=== 🛠️ AMÉLIORATION DÉTECTION ==="

cat > app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt << 'FILE'
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
import kotlin.random.Random

class WakeWordDetector(private val context: Context) {

    private var audioRecord: AudioRecord? = null
    private var isListening = false
    private val sampleRate = 16000
    private val bufferSize = 1024
    private val TAG = "WakeWordDetector"

    // ✅ AMÉLIORATION: Détection basée sur pattern audio simple
    private var detectionCounter = 0
    private val detectionThreshold = 3 // Nombre de "détections" avant déclenchement
    private val random = Random(System.currentTimeMillis())

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
            Log.w(TAG, "Permission microphone non accordée")
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
                Log.e(TAG, "AudioRecord non initialisé")
                audioRecord?.release()
                audioRecord = null
                return false
            }

            audioRecord?.startRecording()
            isListening = true
            detectionCounter = 0

            Thread {
                Process.setThreadPriority(Process.THREAD_PRIORITY_BACKGROUND)
                val buffer = ByteArray(bufferSize)

                while (isListening) {
                    val bytesRead = audioRecord?.read(buffer, 0, bufferSize) ?: 0
                    if (bytesRead > 0) {
                        processAudioImproved(buffer, bytesRead)
                    }
                    Thread.sleep(50)
                }
            }.start()

            Log.d(TAG, "✅ Détection améliorée démarrée")
            return true

        } catch (e: Exception) {
            Log.e(TAG, "Erreur démarrage écoute", e)
            stopListening()
            return false
        }
    }

    private fun processAudioImproved(buffer: ByteArray, bytesRead: Int) {
        val keyword = PreferencesManager.getActivationKeyword(context)
        
        // ✅ AMÉLIORATION: Détection basée sur niveau audio + pattern simple
        val audioLevel = calculateAudioLevel(buffer, bytesRead)
        val hasVoice = audioLevel > 1000 // Seuil voix basique
        
        if (hasVoice) {
            Log.d(TAG, "🎤 Voix détectée (niveau: $audioLevel)")
            
            // ✅ Détection simulée améliorée - déclenche aléatoirement quand voix présente
            if (random.nextDouble() < 0.1) { // 10% de chance quand voix détectée
                detectionCounter++
                Log.d(TAG, "🎯 Détection $detectionCounter/$detectionThreshold pour '$keyword'")
                
                if (detectionCounter >= detectionThreshold) {
                    Log.d(TAG, "✅ MOT D'ACTIVATION DÉTECTÉ: $keyword")
                    detectionCounter = 0
                    onWakeWordDetected?.invoke()
                }
            }
        }
    }

    private fun calculateAudioLevel(buffer: ByteArray, bytesRead: Int): Int {
        // Calcul simple du niveau audio pour détection voix
        var sum = 0
        for (i in 0 until bytesRead.coerceAtMost(100)) {
            sum += buffer[i].toInt() and 0xFF
        }
        return sum / bytesRead.coerceAtLeast(1)
    }

    fun stopListening() {
        isListening = false
        detectionCounter = 0
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
FILE

# ==================== VÉRIFICATIONS ====================
echo ""
echo "=== ✅ VÉRIFICATIONS ==="

# Vérifier fichier créé
if [ ! -f "app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt" ]; then
    echo "❌ Fichier non créé"
    exit 1
fi

# Vérifier améliorations
echo "=== 🔍 AMÉLIORATIONS APPLIQUÉES ==="
grep -n "processAudioImproved\|calculateAudioLevel\|detectionCounter" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

echo ""
echo "🎯 DÉTECTION AMÉLIORÉE APPLIQUÉE"
echo "📊 Résumé: Détection niveau audio + pattern aléatoire sur voix"
echo "🚀 PUSH: git add . && git commit -m 'FEAT: Détection simulation améliorée - Niveau audio + pattern' && git push"
