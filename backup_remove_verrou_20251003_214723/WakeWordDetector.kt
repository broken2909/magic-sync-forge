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
import org.vosk.Model
import org.vosk.Recognizer
import org.json.JSONObject
import java.io.File

class WakeWordDetector(private val context: Context) {

    private var audioRecord: AudioRecord? = null
    private var isListening = false
    private val sampleRate = 16000
    private val bufferSize = 8192
    private val TAG = "WakeWordDetector"
    
    // Composants VOSK
    private var voskModel: Model? = null
    private var voskRecognizer: Recognizer? = null
    private var modelInitialized = false

    // 🔧 VERROU ANTI-BOUCLE
    private var lastDetectionTime = 0L
    private val DETECTION_COOLDOWN = 3000L // 3 secondes

    var onWakeWordDetected: (() -> Unit)? = null
    private var audioThread: Thread? = null

    fun startListening(): Boolean {
        Log.d(TAG, "🎯 Démarrage détection VOSK")
        
        if (isListening) {
            Log.d(TAG, "⚠️ Écoute déjà active")
            return true
        }

        if (!hasMicrophonePermission()) {
            Log.e(TAG, "❌ Permission microphone manquante")
            return false
        }

        // Initialiser VOSK si nécessaire
        if (!modelInitialized && !initializeVoskModel()) {
            Log.e(TAG, "❌ Échec initialisation VOSK")
            return false
        }

        return startAudioRecording()
    }
    
    private fun startAudioRecording(): Boolean {
        try {
            val minBufferSize = AudioRecord.getMinBufferSize(
                sampleRate,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT
            )

            if (minBufferSize == AudioRecord.ERROR || minBufferSize == AudioRecord.ERROR_BAD_VALUE) {
                Log.e(TAG, "❌ Configuration audio invalide")
                return false
            }

            val finalBufferSize = maxOf(minBufferSize * 2, bufferSize)
            Log.d(TAG, "🎧 Buffer audio: $finalBufferSize")

            audioRecord = AudioRecord(
                MediaRecorder.AudioSource.VOICE_RECOGNITION,
                sampleRate,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
                finalBufferSize
            )

            if (audioRecord?.state != AudioRecord.STATE_INITIALIZED) {
                Log.e(TAG, "❌ AudioRecord non initialisé")
                return false
            }

            audioRecord?.startRecording()
            
            if (audioRecord?.recordingState != AudioRecord.RECORDSTATE_RECORDING) {
                Log.e(TAG, "❌ Enregistrement non démarré")
                return false
            }

            isListening = true
            startAudioProcessingThread(finalBufferSize)
            
            Log.d(TAG, "✅ Détection VOSK activée")
            return true

        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur démarrage audio", e)
            return false
        }
    }
    
    private fun startAudioProcessingThread(bufferSize: Int) {
        audioThread = Thread {
            Process.setThreadPriority(Process.THREAD_PRIORITY_URGENT_AUDIO)
            val buffer = ByteArray(bufferSize)
            
            Log.d(TAG, "🔊 Thread audio VOSK démarré")

            try {
                while (isListening && audioRecord != null) {
                    try {
                        val bytesRead = audioRecord?.read(buffer, 0, buffer.size) ?: 0
                        
                        if (bytesRead > 0) {
                            processAudioWithVosk(buffer, bytesRead)
                        } else if (bytesRead < 0) {
                            Log.w(TAG, "⚠️ Erreur lecture audio: $bytesRead")
                            break
                        }
                        
                        Thread.sleep(10)
                        
                    } catch (e: Exception) {
                        Log.e(TAG, "❌ Erreur traitement audio", e)
                        break
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "❌ Erreur thread audio", e)
            }
            
            Log.d(TAG, "🔇 Thread audio terminé")
        }
        
        audioThread?.start()
    }

    private fun initializeVoskModel(): Boolean {
        try {
            Log.d(TAG, "🔄 Initialisation modèle VOSK...")
            
            val currentLanguage = PreferencesManager.getCurrentLanguage(context)
            Log.d(TAG, "🌐 Langue détection: $currentLanguage")
            
            // Chemin du modèle
            val modelPath = File(context.filesDir, "models/$currentLanguage-small").absolutePath
            
            if (!File(modelPath).exists()) {
                Log.e(TAG, "❌ Modèle VOSK manquant: $modelPath")
                // Fallback vers français
                val fallbackPath = File(context.filesDir, "models/fr-small").absolutePath
                if (!File(fallbackPath).exists()) {
                    Log.e(TAG, "❌ Modèle fallback aussi manquant")
                    return false
                }
            }
            
            // Initialiser VOSK
            voskModel = Model(modelPath)
            voskRecognizer = Recognizer(voskModel, sampleRate.toFloat())
            
            modelInitialized = true
            Log.d(TAG, "✅ Modèle VOSK initialisé - Langue: $currentLanguage")
            return true
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur initialisation VOSK", e)
            return false
        }
    }

    private fun processAudioWithVosk(buffer: ByteArray, bytesRead: Int) {
        try {
            val recognizer = voskRecognizer ?: return
            
            if (recognizer.acceptWaveForm(buffer, bytesRead)) {
                val result = recognizer.result
                processVoskResult(result, false)
            } else {
                val partialResult = recognizer.partialResult
                if (partialResult.isNotEmpty()) {
                    processVoskResult(partialResult, true)
                }
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur traitement VOSK", e)
        }
    }
    
    private fun processVoskResult(result: String, isPartial: Boolean) {
        try {
            if (result.isEmpty() || result == "{}") return
            
            val json = JSONObject(result)
            val text = if (isPartial) {
                json.optString("partial", "").trim()
            } else {
                json.optString("text", "").trim()
            }
            
            if (text.isNotEmpty()) {
                val logType = if (isPartial) "🔍 Partiel" else "🎯 Final"
                Log.d(TAG, "$logType VOSK: '$text'")
                
                if (!isPartial || text.length > 2) {
                    checkForWakeWord(text)
                }
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur parsing VOSK", e)
        }
    }
    
    private fun checkForWakeWord(text: String) {
        try {
            // 🔧 VÉRIFICATION ANTI-BOUCLE
            val now = System.currentTimeMillis()
            if (now - lastDetectionTime < DETECTION_COOLDOWN) {
                Log.d(TAG, "⏳ Verrou anti-boucle actif - Ignorer détection")
                return
            }
            
            val keyword = PreferencesManager.getActivationKeyword(context).lowercase().trim()
            val normalizedText = text.lowercase().trim()
            
            // Recherche flexible du mot-clé
            val found = normalizedText.contains(keyword) ||
                      normalizedText.split(" ").any { word -> 
                          word == keyword || 
                          calculateSimilarity(word, keyword) > 0.7
                      }
            
            if (found) {
                lastDetectionTime = now // 🔧 METTRE À JOUR TIMESTAMP
                Log.d(TAG, "🎉🎉 MOT-CLÉ DÉTECTÉ: '$keyword' dans '$text' 🎉🎉")
                
                try {
                    onWakeWordDetected?.invoke()
                } catch (e: Exception) {
                    Log.e(TAG, "❌ Erreur callback détection", e)
                }
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur vérification mot-clé", e)
        }
    }
    
    private fun calculateSimilarity(s1: String, s2: String): Double {
        if (s1 == s2) return 1.0
        if (s1.isEmpty() || s2.isEmpty()) return 0.0
        
        val longer = if (s1.length > s2.length) s1 else s2
        val shorter = if (s1.length > s2.length) s2 else s1
        
        return if (longer.length == 0) 1.0 
        else (longer.length - editDistance(longer, shorter)) / longer.length.toDouble()
    }
    
    private fun editDistance(s1: String, s2: String): Int {
        val dp = Array(s1.length + 1) { IntArray(s2.length + 1) }
        
        for (i in 0..s1.length) dp[i][0] = i
        for (j in 0..s2.length) dp[0][j] = j
        
        for (i in 1..s1.length) {
            for (j in 1..s2.length) {
                val cost = if (s1[i-1] == s2[j-1]) 0 else 1
                dp[i][j] = minOf(
                    dp[i-1][j] + 1,      // deletion
                    dp[i][j-1] + 1,      // insertion  
                    dp[i-1][j-1] + cost  // substitution
                )
            }
        }
        
        return dp[s1.length][s2.length]
    }

    fun stopListening() {
        Log.d(TAG, "🛑 Arrêt détection")
        isListening = false
        
        try {
            audioThread?.interrupt()
            audioThread = null
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur arrêt thread", e)
        }
        
        try {
            audioRecord?.stop()
            audioRecord?.release()
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur arrêt AudioRecord", e)
        }
        audioRecord = null
    }

    fun isListening(): Boolean = isListening

    private fun hasMicrophonePermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            context,
            android.Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
    }
    
    fun cleanup() {
        Log.d(TAG, "🧹 Nettoyage VOSK")
        stopListening()
        
        try {
            voskRecognizer = null
            voskModel?.close()
            voskModel = null
            modelInitialized = false
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur cleanup VOSK", e)
        }
    }
}
