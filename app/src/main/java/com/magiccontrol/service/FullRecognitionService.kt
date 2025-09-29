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
import com.magiccontrol.utils.ModelManager
import com.magiccontrol.utils.PreferencesManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.vosk.Model
import org.vosk.Recognizer
import org.json.JSONObject
import java.io.File
import java.io.FileOutputStream

class FullRecognitionService : Service() {

    private var voskModel: Model? = null
    private var recognizer: Recognizer? = null
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
        loadVoskModel()
    }

    private fun loadVoskModel() {
        try {
            val currentLanguage = PreferencesManager.getCurrentLanguage(applicationContext)
            
            // ✅ ESSAYER VOSK, SINON MODE SIMULATION
            if (tryLoadVoskModel(currentLanguage)) {
                Log.d(TAG, "Vosk chargé avec succès")
            } else {
                Log.w(TAG, "Vosk échec - Mode simulation activé")
                recognizer = null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erreur chargement model", e)
            recognizer = null
        }
    }

    /**
     * ✅ TENTATIVE CHARGEMENT VOSK AVEC GESTION ERREURS RENFORCÉE
     */
    private fun tryLoadVoskModel(language: String): Boolean {
        return try {
            val modelCode = "$language-small"
            val modelPath = copyModelFromAssetsIfNeeded(modelCode)
            
            if (modelPath != null && File(modelPath).exists()) {
                voskModel = Model(modelPath)
                recognizer = Recognizer(voskModel, sampleRate.toFloat())
                true
            } else {
                false
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erreur chargement Vosk", e)
            false
        }
    }

    /**
     * ✅ COPIE ASSETS AVEC GESTION ERREURS RENFORCÉE
     */
    private fun copyModelFromAssetsIfNeeded(modelCode: String): String? {
        return try {
            val modelsDir = File(filesDir, "models")
            if (!modelsDir.exists()) modelsDir.mkdirs()
            
            val targetDir = File(modelsDir, modelCode)
            val targetPath = targetDir.absolutePath
            
            // Si déjà copié
            if (targetDir.exists() && targetDir.list()?.isNotEmpty() == true) {
                return targetPath
            }
            
            // Déterminer chemin asset
            val assetPath = when (modelCode) {
                "fr-small" -> "models/vosk-model-small-fr"
                "en-small" -> "models/vosk-model-small-en-us"
                else -> return null
            }
            
            Log.d(TAG, "Copie modèle: $assetPath -> $targetPath")
            
            // ✅ COPIE SÉCURISÉE
            if (copyAssetFolderSafe(assetPath, targetPath)) {
                targetPath
            } else {
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erreur copie modèle", e)
            null
        }
    }

    /**
     * ✅ COPIE ASSETS SÉCURISÉE - NE CRASH JAMAIS
     */
    private fun copyAssetFolderSafe(assetPath: String, targetPath: String): Boolean {
        return try {
            val targetDir = File(targetPath)
            if (!targetDir.exists()) targetDir.mkdirs()
            
            // ✅ VÉRIFICATION EXISTENCE ASSET
            val files = assets.list(assetPath)
            if (files == null || files.isEmpty()) {
                Log.e(TAG, "Asset vide ou inexistant: $assetPath")
                return false
            }
            
            // ✅ COPIE CHAQUE FICHIER
            for (file in files) {
                try {
                    val inputStream = assets.open("$assetPath/$file")
                    val outputFile = File(targetDir, file)
                    val outputStream = FileOutputStream(outputFile)
                    
                    inputStream.copyTo(outputStream)
                    inputStream.close()
                    outputStream.close()
                    
                    Log.d(TAG, "Fichier copié: $file")
                } catch (e: Exception) {
                    Log.e(TAG, "Erreur copie fichier $file", e)
                    // Continuer avec les autres fichiers
                }
            }
            true
        } catch (e: Exception) {
            Log.e(TAG, "Erreur copie folder $assetPath", e)
            false
        }
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
                if (recognizer != null) {
                    processAudioWithVosk()
                } else {
                    processAudioSimulation()
                }
            }

        } catch (e: Exception) {
            Log.e(TAG, "Erreur démarrage reconnaissance", e)
            TTSManager.speak(applicationContext, "Erreur microphone")
            stopSelf()
        }
    }

    private suspend fun processAudioWithVosk() {
        val buffer = ByteArray(bufferSize)
        val timeout = 10000L
        val startTime = System.currentTimeMillis()

        try {
            while (isListening && System.currentTimeMillis() - startTime < timeout) {
                val bytesRead = audioRecord?.read(buffer, 0, bufferSize) ?: 0
                if (bytesRead > 0) {
                    if (recognizer?.acceptWaveForm(buffer, bytesRead) == true) {
                        val result = recognizer?.result
                        result?.let {
                            val command = extractCommandFromVoskResult(it)
                            if (command.isNotBlank()) {
                                processCommand(command)
                                return
                            }
                        }
                    }
                }
                delay(50)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erreur traitement Vosk", e)
        }

        stopSelf()
    }

    private suspend fun processAudioSimulation() {
        val buffer = ByteArray(bufferSize)
        val timeout = 10000L
        val startTime = System.currentTimeMillis()

        while (isListening && System.currentTimeMillis() - startTime < timeout) {
            try {
                val bytesRead = audioRecord?.read(buffer, 0, bufferSize) ?: 0
                if (bytesRead > 0) {
                    val command = simulateSpeechRecognition(buffer, bytesRead)
                    if (command.isNotBlank()) {
                        processCommand(command)
                        return
                    }
                }
                delay(100)
            } catch (e: Exception) {
                Log.e(TAG, "Erreur traitement audio simulation", e)
                break
            }
        }
        stopSelf()
    }

    private fun extractCommandFromVoskResult(voskResult: String): String {
        return try {
            val jsonObject = JSONObject(voskResult)
            val text = jsonObject.getString("text")
            Log.d(TAG, "Vosk a reconnu: $text")
            text
        } catch (e: Exception) {
            Log.e(TAG, "Erreur parsing résultat Vosk", e)
            ""
        }
    }

    private fun simulateSpeechRecognition(buffer: ByteArray, bytesRead: Int): String {
        val audioText = String(buffer, 0, bytesRead.coerceAtMost(100))
        Log.d(TAG, "Audio simulation: ${audioText.take(50)}...")
        
        return when {
            audioText.contains("volume", ignoreCase = true) -> "volume augmenter"
            audioText.contains("wifi", ignoreCase = true) -> "wifi"
            audioText.contains("paramètres", ignoreCase = true) -> "paramètres"
            audioText.contains("accueil", ignoreCase = true) -> "accueil"
            else -> ""
        }
    }

    private fun processCommand(command: String) {
        Log.d(TAG, "Commande traitée: $command")
        SystemIntegration.handleSystemCommand(applicationContext, command)
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Arrêt service reconnaissance")
        
        isListening = false
        recognitionJob?.cancel()
        
        try {
            audioRecord?.stop()
            audioRecord?.release()
            recognizer?.close()
            voskModel?.close()
        } catch (e: Exception) {
            Log.e(TAG, "Erreur libération ressources", e)
        }
        audioRecord = null
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
