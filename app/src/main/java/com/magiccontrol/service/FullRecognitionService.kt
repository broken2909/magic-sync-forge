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
import com.magiccontrol.utils.PreferencesManager
import com.magiccontrol.system.SystemIntegration
import org.vosk.Model
import org.vosk.Recognizer
import org.json.JSONObject
import java.io.File

class FullRecognitionService : Service() {

    private val TAG = "FullRecognitionService"
    private var audioRecord: AudioRecord? = null
    private var isListening = false
    private val sampleRate = 16000
    private val bufferSize = 8192
    
    // VOSK pour reconnaissance complète
    private var voskModel: Model? = null
    private var voskRecognizer: Recognizer? = null
    
    private var recognitionThread: Thread? = null
    private var recognitionActive = false

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "🎯 Service reconnaissance créé")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "🔊 Démarrage reconnaissance commandes")
        
        try {
            // Message d'activation
            TTSManager.speak(applicationContext, "Que voulez-vous faire ?")
            
            // Démarrer après délai TTS
            Handler(Looper.getMainLooper()).postDelayed({
                startFullRecognition()
            }, 1500L)
            
            // Timeout automatique après 15 secondes
            Handler(Looper.getMainLooper()).postDelayed({
                if (recognitionActive) {
                    Log.d(TAG, "⏰ Timeout reconnaissance")
                    TTSManager.speak(applicationContext, "Aucune commande détectée")
                    stopSelf()
                }
            }, 15000L)
            
            return START_NOT_STICKY
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur démarrage reconnaissance", e)
            stopSelf()
            return START_NOT_STICKY
        }
    }

    private fun startFullRecognition() {
        try {
            Log.d(TAG, "🔄 Initialisation reconnaissance complète...")
            
            // Initialiser VOSK
            if (!initializeVoskModel()) {
                TTSManager.speak(applicationContext, "Erreur reconnaissance")
                stopSelf()
                return
            }
            
            // Initialiser audio
            if (!initializeAudioRecord()) {
                TTSManager.speak(applicationContext, "Erreur microphone")
                stopSelf()
                return
            }
            
            // Démarrer thread reconnaissance
            startRecognitionThread()
            
            Log.d(TAG, "✅ Reconnaissance commandes ACTIVÉE")
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur reconnaissance", e)
            stopSelf()
        }
    }
    
    private fun initializeVoskModel(): Boolean {
        try {
            Log.d(TAG, "🧠 Initialisation VOSK reconnaissance...")
            
            val currentLanguage = PreferencesManager.getCurrentLanguage(applicationContext)
            val modelPath = File(applicationContext.filesDir, "models/$currentLanguage-small").absolutePath
            
            if (!File(modelPath).exists()) {
                Log.e(TAG, "❌ Modèle VOSK manquant")
                return false
            }
            
            voskModel = Model(modelPath)
            voskRecognizer = Recognizer(voskModel, sampleRate.toFloat())
            
            Log.d(TAG, "✅ VOSK reconnaissance initialisé")
            return true
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur VOSK reconnaissance", e)
            return false
        }
    }
    
    private fun initializeAudioRecord(): Boolean {
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
            Log.d(TAG, "✅ AudioRecord reconnaissance initialisé")
            return true

        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur initialisation audio", e)
            return false
        }
    }
    
    private fun startRecognitionThread() {
        recognitionActive = true
        
        recognitionThread = Thread {
            Process.setThreadPriority(Process.THREAD_PRIORITY_URGENT_AUDIO)
            val buffer = ByteArray(bufferSize)
            var silenceCount = 0
            val maxSilence = 30 // 1.5 secondes
            
            Log.d(TAG, "🎧 Thread reconnaissance démarré")

            try {
                while (recognitionActive && isListening) {
                    try {
                        val bytesRead = audioRecord?.read(buffer, 0, buffer.size) ?: 0
                        
                        if (bytesRead > 0) {
                            val hasSound = processRecognitionAudio(buffer, bytesRead)
                            
                            if (hasSound) {
                                silenceCount = 0
                            } else {
                                silenceCount++
                            }
                            
                            // Arrêt si silence prolongé
                            if (silenceCount >= maxSilence) {
                                Log.d(TAG, "🔇 Silence détecté - arrêt écoute")
                                break
                            }
                            
                        } else if (bytesRead < 0) {
                            Log.w(TAG, "⚠️ Erreur lecture audio")
                            break
                        }
                        
                        Thread.sleep(50)
                        
                    } catch (e: Exception) {
                        Log.e(TAG, "❌ Erreur thread reconnaissance", e)
                        break
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "❌ Erreur critique thread", e)
            }
            
            Log.d(TAG, "🛑 Thread reconnaissance terminé")
            
            // Auto-stop
            Handler(Looper.getMainLooper()).post {
                stopSelf()
            }
        }
        
        recognitionThread?.start()
    }
    
    private fun processRecognitionAudio(buffer: ByteArray, bytesRead: Int): Boolean {
        try {
            val recognizer = voskRecognizer ?: return false
            
            if (recognizer.acceptWaveForm(buffer, bytesRead)) {
                val result = recognizer.result
                processRecognitionResult(result)
                return true
            }
            
            return checkAudioActivity(buffer, bytesRead)
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur traitement audio", e)
            return false
        }
    }
    
    private fun checkAudioActivity(buffer: ByteArray, bytesRead: Int): Boolean {
        try {
            var sum = 0L
            var samples = 0
            
            for (i in 0 until bytesRead step 2) {
                if (i + 1 < bytesRead) {
                    val sample = ((buffer[i + 1].toInt() and 0xFF) shl 8) or (buffer[i].toInt() and 0xFF)
                    sum += kotlin.math.abs(sample.toShort().toInt())
                    samples++
                }
            }
            
            return if (samples > 0) {
                val average = sum / samples
                average > 300 // Seuil activité audio
            } else false
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur détection activité", e)
            return false
        }
    }
    
    private fun processRecognitionResult(result: String) {
        try {
            if (result.isEmpty() || result == "{}") return
            
            val json = JSONObject(result)
            val text = json.optString("text", "").trim()
            
            if (text.isNotEmpty()) {
                Log.d(TAG, "🎯 COMMANDE DÉTECTÉE: '$text'")
                
                // Arrêter l'écoute immédiatement
                recognitionActive = false
                
                // Traiter la commande
                Handler(Looper.getMainLooper()).post {
                    executeSystemCommand(text)
                }
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur parsing résultat", e)
        }
    }
    
    private fun executeSystemCommand(command: String) {
        try {
            Log.d(TAG, "⚡ Exécution commande: '$command'")
            
            val normalizedCommand = command.lowercase().trim()
            
            // Commandes de volume
            if (normalizedCommand.contains("volume") || normalizedCommand.contains("son")) {
                if (normalizedCommand.contains("plus") || normalizedCommand.contains("augmenter")) {
                    SystemIntegration.handleSystemCommand(applicationContext, "volume plus")
                    TTSManager.speak(applicationContext, "Volume augmenté")
                } else if (normalizedCommand.contains("moins") || normalizedCommand.contains("baisser")) {
                    SystemIntegration.handleSystemCommand(applicationContext, "volume moins") 
                    TTSManager.speak(applicationContext, "Volume baissé")
                }
            }
            
            // Navigation
            else if (normalizedCommand.contains("accueil") || normalizedCommand.contains("home")) {
                SystemIntegration.handleSystemCommand(applicationContext, "accueil")
                TTSManager.speak(applicationContext, "Retour à l'accueil")
            }
            else if (normalizedCommand.contains("retour") || normalizedCommand.contains("back")) {
                SystemIntegration.handleSystemCommand(applicationContext, "retour")
                TTSManager.speak(applicationContext, "Retour")
            }
            
            // Applications
            else if (normalizedCommand.contains("paramètre") || normalizedCommand.contains("setting")) {
                SystemIntegration.handleSystemCommand(applicationContext, "ouvrir paramètres")
                TTSManager.speak(applicationContext, "Ouverture des paramètres")
            }
            else if (normalizedCommand.contains("calculatrice")) {
                SystemIntegration.handleSystemCommand(applicationContext, "ouvrir calculatrice")
                TTSManager.speak(applicationContext, "Calculatrice")
            }
            
            // Commandes non reconnues
            else {
                Log.w(TAG, "⚠️ Commande non reconnue: '$command'")
                TTSManager.speak(applicationContext, "Commande non reconnue. Essayez: volume plus, accueil, paramètres")
            }
            
            // Arrêt différé
            Handler(Looper.getMainLooper()).postDelayed({
                stopSelf()
            }, 2000L)
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur exécution commande", e)
            TTSManager.speak(applicationContext, "Erreur commande")
            stopSelf()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
    
    // 🔧 REDÉMARRER ÉCOUTE PERMANENTE
    val wakeIntent = Intent(this, WakeWordService::class.java)
    startService(wakeIntent)
        Log.d(TAG, "🔚 Service reconnaissance arrêté")
        
        recognitionActive = false
        isListening = false
        
        try {
            recognitionThread?.interrupt()
            recognitionThread = null
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur arrêt thread", e)
        }
        
        try {
            audioRecord?.stop()
            audioRecord?.release()
            audioRecord = null
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur arrêt audio", e)
        }
        
        try {
            voskRecognizer = null
            voskModel?.close()
            voskModel = null
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur cleanup VOSK", e)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
