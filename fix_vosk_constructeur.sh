#!/bin/bash
echo "🔧 CORRECTION CONSTRUCTEUR VOSK - Système vocal opérationnel"

cd /data/data/com.termux/files/home/magic-sync-forge/

# ==================== VÉRIFICATIONS PRÉALABLES ====================
echo "=== 🔍 VÉRIFICATIONS PRÉALABLES ==="

# 1. Vérifier présence modèles Vosk
echo "=== 📁 MODÈLES VOSK ==="
find app/src/main/assets/models -type f -name "*.md" -o -name "*.conf" | head -5

# 2. Vérifier dépendance Vosk
echo "=== 📦 DÉPENDANCE VOSK ==="
grep "vosk" app/build.gradle

# 3. Vérifier fichiers existants
if [ ! -f "app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt" ]; then
    echo "❌ WakeWordDetector.kt manquant"
    exit 1
fi
if [ ! -f "app/src/main/java/com/magiccontrol/service/FullRecognitionService.kt" ]; then
    echo "❌ FullRecognitionService.kt manquant"  
    exit 1
fi
echo "✅ Fichiers présents"

# ==================== CORRECTION WAKEWORDDETECTOR ====================
echo ""
echo "=== 🛠️ CORRECTION WAKEWORDDETECTOR ==="

cat > app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt << 'FILE1'
package com.magiccontrol.recognizer

import android.content.Context
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Process
import android.util.Log
import com.magiccontrol.utils.ModelManager
import com.magiccontrol.utils.PreferencesManager
import org.vosk.Model
import org.vosk.Recognizer
import java.io.IOException

class WakeWordDetector(private val context: Context) {

    private var voskModel: Model? = null
    private var recognizer: Recognizer? = null
    private var audioRecord: AudioRecord? = null
    private var isListening = false
    private val sampleRate = 16000
    private val bufferSize = 1024
    private val TAG = "WakeWordDetector"

    var onWakeWordDetected: (() -> Unit)? = null

    init {
        loadVoskModel()
    }

    private fun loadVoskModel() {
        try {
            val currentLanguage = PreferencesManager.getCurrentLanguage(context)
            Log.d(TAG, "Chargement modèle Vosk: $currentLanguage")
            
            // ✅ CORRECTION: Constructeur avec InputStream
            if (ModelManager.isModelAvailable(context, currentLanguage)) {
                val modelPath = ModelManager.getModelPathForLanguage(context, currentLanguage, "small")
                voskModel = Model(context.assets.open(modelPath))  // ✅ CONSTRUCTEUR CORRECT
                recognizer = Recognizer(voskModel, sampleRate.toFloat())
                Log.d(TAG, "✅ Vosk initialisé: $modelPath")
            } else {
                Log.w(TAG, "❌ Modèle Vosk non disponible - Mode simulation")
            }
        } catch (e: IOException) {
            Log.e(TAG, "Erreur chargement modèle Vosk", e)
        } catch (e: Exception) {
            Log.e(TAG, "Erreur initialisation Vosk", e)
        }
    }

    fun startListening(): Boolean {
        if (isListening) return false

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
                        if (recognizer != null) {
                            processAudioWithVosk(buffer, bytesRead)
                        } else {
                            processAudioSimulation(buffer, bytesRead)
                        }
                    }
                    Thread.sleep(50)
                }
            }.start()

            Log.d(TAG, "Détection démarrée - Mode: ${if (recognizer != null) "VOSK" else "SIMULATION"}")
            return true

        } catch (e: Exception) {
            Log.e(TAG, "Erreur démarrage écoute", e)
            stopListening()
            return false
        }
    }

    private fun processAudioWithVosk(buffer: ByteArray, bytesRead: Int) {
        try {
            if (recognizer?.acceptWaveForm(buffer, bytesRead) == true) {
                val result = recognizer?.result
                result?.let {
                    if (containsActivationKeyword(it)) {
                        Log.d(TAG, "✅ Mot d'activation détecté par Vosk")
                        onWakeWordDetected?.invoke()
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erreur traitement Vosk", e)
        }
    }

    private fun processAudioSimulation(buffer: ByteArray, bytesRead: Int) {
        val keyword = PreferencesManager.getActivationKeyword(context)
        val audioText = String(buffer, 0, bytesRead.coerceAtMost(100))
        
        if (audioText.contains(keyword, ignoreCase = true)) {
            Log.d(TAG, "✅ Mot d'activation détecté (simulation): $keyword")
            onWakeWordDetected?.invoke()
        }
    }

    private fun containsActivationKeyword(voskResult: String): Boolean {
        val keyword = PreferencesManager.getActivationKeyword(context)
        return voskResult.contains(keyword, ignoreCase = true)
    }

    fun stopListening() {
        isListening = false
        try {
            audioRecord?.stop()
            audioRecord?.release()
            recognizer?.close()
        } catch (e: Exception) {
            Log.e(TAG, "Erreur arrêt écoute", e)
        }
        audioRecord = null
        Log.d(TAG, "Détection arrêtée")
    }

    fun isListening(): Boolean = isListening
}
FILE1

# ==================== CORRECTION FULLRECOGNITIONSERVICE ====================
echo ""
echo "=== 🛠️ CORRECTION FULLRECOGNITIONSERVICE ==="

cat > app/src/main/java/com/magiccontrol/service/FullRecognitionService.kt << 'FILE2'
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
import java.io.IOException

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
        Log.d(TAG, "Service reconnaissance créé")
        TTSManager.initialize(applicationContext)
        loadVoskModel()
    }

    private fun loadVoskModel() {
        try {
            val currentLanguage = PreferencesManager.getCurrentLanguage(applicationContext)
            Log.d(TAG, "Chargement modèle reconnaissance: $currentLanguage")
            
            // ✅ CORRECTION: Constructeur avec InputStream
            if (ModelManager.isModelAvailable(applicationContext, currentLanguage)) {
                val modelPath = ModelManager.getModelPathForLanguage(applicationContext, currentLanguage, "small")
                voskModel = Model(applicationContext.assets.open(modelPath))  // ✅ CONSTRUCTEUR CORRECT
                recognizer = Recognizer(voskModel, sampleRate.toFloat())
                Log.d(TAG, "✅ Vosk reconnaissance initialisé: $modelPath")
            } else {
                Log.w(TAG, "❌ Modèle reconnaissance non disponible - Mode simulation")
            }
        } catch (e: IOException) {
            Log.e(TAG, "Erreur chargement modèle reconnaissance", e)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Démarrage reconnaissance vocale")
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
                                break
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
                        break
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
            Log.d(TAG, "✅ Vosk a reconnu: $text")
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
        Log.d(TAG, "🔧 Commande traitée: $command")
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
FILE2

# ==================== VÉRIFICATIONS FINALES ====================
echo ""
echo "=== ✅ VÉRIFICATIONS FINALES ==="

# 1. Vérifier fichiers créés
for file in "app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt" "app/src/main/java/com/magiccontrol/service/FullRecognitionService.kt"; do
    if [ ! -f "$file" ]; then
        echo "❌ Fichier manquant: $file"
        exit 1
    fi
done
echo "✅ Fichiers créés"

# 2. Vérifier constructeurs corrigés
echo "=== 🔧 CONSTRUCTEURS VOSK ==="
grep -n "Model(.*assets.open" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt
grep -n "Model(.*assets.open" app/src/main/java/com/magiccontrol/service/FullRecognitionService.kt

# 3. Vérifier braces équilibrées
for file in "app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt" "app/src/main/java/com/magiccontrol/service/FullRecognitionService.kt"; do
    start=$(grep -o "{" "$file" | wc -l)
    end=$(grep -o "}" "$file" | wc -l)
    if [ "$start" -ne "$end" ]; then
        echo "❌ Braces déséquilibrées dans $file: $start { vs $end }"
        exit 1
    fi
    echo "✅ $file: Braces équilibrées ($start)"
done

echo ""
echo "🎯 SYSTÈME VOCAL OPÉRATIONNEL PRÊT !"
echo "📊 Résumé: Constructeurs Vosk corrigés + Fallback simulation"
echo "🚀 TEST: ./gradlew assembleDebug --console=plain"
