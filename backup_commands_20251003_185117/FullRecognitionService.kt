package com.magiccontrol.service

import android.app.Service
import android.content.Intent
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.Process
import android.util.Log
import com.magiccontrol.tts.TTSManager
import com.magiccontrol.utils.ModelManager
import com.magiccontrol.utils.PreferencesManager
import com.magiccontrol.command.CommandProcessor
import org.vosk.Model
import org.vosk.Recognizer
import org.json.JSONObject
import java.io.File

class FullRecognitionService : Service() {

    private val TAG = "FullRecognitionService"
    private var audioRecord: AudioRecord? = null
    private var isListening = false
    private val sampleRate = 16000
    private val bufferSize = 1024
    
    // VOSK Components
    private var voskModel: Model? = null
    private var voskRecognizer: Recognizer? = null
    
    // Command processing
    private lateinit var commandProcessor: CommandProcessor

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service de reconnaissance complète créé")
        commandProcessor = CommandProcessor(applicationContext)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "🎤 Démarrage reconnaissance vocale complète avec VOSK")
        
        // Feedback vocal immédiat
        TTSManager.speak(applicationContext, "Dites votre commande")
        
        // Démarrer reconnaissance après délai TTS
        Handler(Looper.getMainLooper()).postDelayed({
            startFullRecognition()
        }, 1500L)
        
        return START_NOT_STICKY
    }

    private fun startFullRecognition() {
        try {
            // Initialize VOSK
            if (!initializeVoskModel()) {
                TTSManager.speak(applicationContext, "Erreur reconnaissance vocale")
                stopSelf()
                return
            }
            
            // Initialize AudioRecord
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

            if (audioRecord?.state != AudioRecord.STATE_INITIALIZED) {
                Log.e(TAG, "AudioRecord non initialisé")
                TTSManager.speak(applicationContext, "Erreur microphone")
                stopSelf()
                return
            }

            audioRecord?.startRecording()
            isListening = true
            
            Log.d(TAG, "🔊 Écoute de commande démarrée")

            // Thread d'écoute avec timeout
            Thread {
                Process.setThreadPriority(Process.THREAD_PRIORITY_BACKGROUND)
                val buffer = ByteArray(bufferSize)
                var silenceCount = 0
                val maxSilence = 150 // 7.5 secondes à 50ms par cycle

                while (isListening && silenceCount < maxSilence) {
                    val bytesRead = audioRecord?.read(buffer, 0, bufferSize) ?: 0
                    if (bytesRead > 0) {
                        val hasSound = processAudioWithVosk(buffer, bytesRead)
                        if (hasSound) {
                            silenceCount = 0 // Reset silence counter
                        } else {
                            silenceCount++
                        }
                    }
                    Thread.sleep(50)
                }
                
                if (silenceCount >= maxSilence) {
                    Log.d(TAG, "Timeout écoute - arrêt service")
                    stopSelf()
                }
            }.start()

        } catch (e: Exception) {
            Log.e(TAG, "Erreur démarrage reconnaissance", e)
            TTSManager.speak(applicationContext, "Erreur reconnaissance")
            stopSelf()
        }
    }
    
    private fun initializeVoskModel(): Boolean {
        try {
            val currentLanguage = PreferencesManager.getCurrentLanguage(applicationContext)
            val absoluteModelPath = File(applicationContext.filesDir, "models/$currentLanguage-small").absolutePath
            
            if (!File(absoluteModelPath).exists()) {
                Log.e(TAG, "Modèle VOSK inexistant: $absoluteModelPath")
                return false
            }
            
            voskModel = Model(absoluteModelPath)
            voskRecognizer = Recognizer(voskModel, sampleRate.toFloat())
            
            Log.d(TAG, "Modèle VOSK reconnaissance complète initialisé")
            return true
            
        } catch (e: Exception) {
            Log.e(TAG, "Erreur initialisation VOSK reconnaissance", e)
            return false
        }
    }
    
    private fun processAudioWithVosk(buffer: ByteArray, bytesRead: Int): Boolean {
        try {
            val recognizer = voskRecognizer ?: return false
            
            // Check for sound activity
            val hasSound = checkAudioActivity(buffer, bytesRead)
            
            if (recognizer.acceptWaveForm(buffer, bytesRead)) {
                val result = recognizer.result
                processVoskResult(result)
            }
            
            return hasSound
            
        } catch (e: Exception) {
            Log.e(TAG, "Erreur traitement audio reconnaissance", e)
            return false
        }
    }
    
    private fun checkAudioActivity(buffer: ByteArray, bytesRead: Int): Boolean {
        var sum = 0L
        for (i in 0 until bytesRead step 2) {
            val sample = (buffer[i].toInt() or (buffer[i + 1].toInt() shl 8)).toShort()
            sum += kotlin.math.abs(sample.toInt())
        }
        val average = sum / (bytesRead / 2)
        return average > 1000 // Threshold for sound detection
    }
    
    private fun processVoskResult(result: String) {
        try {
            val json = JSONObject(result)
            val text = json.optString("text", "").trim()
            
            if (text.isNotEmpty()) {
                Log.d(TAG, "🗣️ Commande reconnue: '$text'")
                
                // Process command
                Handler(Looper.getMainLooper()).post {
                    commandProcessor.processCommand(text) { success ->
                        if (success) {
                            TTSManager.speak(applicationContext, "Commande exécutée")
                        } else {
                            TTSManager.speak(applicationContext, "Commande non reconnue")
                        }
                        // Stop service after processing
                        stopSelf()
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erreur parsing résultat reconnaissance", e)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Arrêt service reconnaissance complète")
        
        isListening = false
        
        try {
            audioRecord?.stop()
            audioRecord?.release()
            audioRecord = null
        } catch (e: Exception) {
            Log.e(TAG, "Erreur arrêt AudioRecord", e)
        }
        
        try {
            voskRecognizer = null
            voskModel?.close()
            voskModel = null
        } catch (e: Exception) {
            Log.e(TAG, "Erreur nettoyage VOSK", e)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
