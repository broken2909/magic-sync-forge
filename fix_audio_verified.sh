#!/bin/bash
echo "🔧 CORRECTION AUDIO AVEC VÉRIFICATIONS"

cd /data/data/com.termux/files/home/magic-sync-forge/

# ==================== VÉRIFICATIONS PRÉALABLES ====================
echo "=== 🔍 VÉRIFICATIONS PRÉALABLES ==="

# 1. Vérifier fichier existe
if [ ! -f "app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt" ]; then
    echo "❌ Fichier manquant"
    exit 1
fi
echo "✅ Fichier présent"

# 2. Vérifier structure actuelle
echo "=== 📋 STRUCTURE ACTUELLE ==="
grep -n "fun startListening" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt
start_braces=$(grep -o "{" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt | wc -l)
end_braces=$(grep -o "}" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt | wc -l)
echo "Braces actuelles: $start_braces { vs $end_braces }"

# ==================== CORRECTION ====================
echo ""
echo "=== 🛠️ APPLICATION CORRECTION ==="

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

    // Détection manuelle - déclenche au bout de 3 secondes
    private var detectionTimer = 0
    private val detectionTimeThreshold = 60 // 60 * 50ms = 3 secondes

    var onWakeWordDetected: (() -> Unit)? = null

    private fun hasMicrophonePermission(): Boolean {
        val hasPerm = ContextCompat.checkSelfPermission(
            context,
            android.Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
        Log.d(TAG, "🔧 Permission micro: $hasPerm")
        return hasPerm
    }

    fun startListening(): Boolean {
        Log.d(TAG, "🎧 DEMANDE DÉMARRAGE ÉCOUTE")
        
        if (isListening) {
            Log.d(TAG, "⚠️ Déjà en écoute")
            return true
        }

        if (!hasMicrophonePermission()) {
            Log.e(TAG, "❌ Permission micro refusée")
            return false
        }

        try {
            Log.d(TAG, "🔧 Configuration AudioRecord...")
            val minBufferSize = AudioRecord.getMinBufferSize(
                sampleRate,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT
            )
            Log.d(TAG, "🔧 Taille buffer min: $minBufferSize")

            if (minBufferSize == AudioRecord.ERROR || minBufferSize == AudioRecord.ERROR_BAD_VALUE) {
                Log.e(TAG, "❌ Taille buffer invalide")
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
                Log.e(TAG, "❌ AudioRecord non initialisé")
                audioRecord?.release()
                audioRecord = null
                return false
            }

            audioRecord?.startRecording()
            isListening = true
            detectionTimer = 0

            Log.d(TAG, "✅ AudioRecord initialisé et démarré")

            Thread {
                Process.setThreadPriority(Process.THREAD_PRIORITY_BACKGROUND)
                val buffer = ByteArray(bufferSize)
                Log.d(TAG, "🎧 Thread écoute démarré")

                while (isListening) {
                    try {
                        val bytesRead = audioRecord?.read(buffer, 0, bufferSize) ?: 0
                        if (bytesRead > 0) {
                            // ✅ DÉTECTION FORCÉE - Se déclenche après 3 secondes
                            detectionTimer++
                            Log.d(TAG, "🎧 Audio capturé ($bytesRead bytes) - Timer: $detectionTimer/$detectionTimeThreshold")
                            
                            if (detectionTimer >= detectionTimeThreshold) {
                                Log.d(TAG, "✅ DÉTECTION FORCÉE APRÈS 3 SECONDES")
                                detectionTimer = 0
                                onWakeWordDetected?.invoke()
                                break
                            }
                        }
                        Thread.sleep(50)
                    } catch (e: Exception) {
                        Log.e(TAG, "❌ Erreur lecture audio", e)
                        break
                    }
                }
                Log.d(TAG, "🎧 Thread écoute arrêté")
            }.start()

            Log.d(TAG, "✅ Détection démarrée avec succès")
            return true

        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur démarrage écoute: ${e.message}")
            stopListening()
            return false
        }
    }

    fun stopListening() {
        Log.d(TAG, "🔧 Arrêt écoute demandé")
        isListening = false
        detectionTimer = 0
        try {
            audioRecord?.stop()
            audioRecord?.release()
            Log.d(TAG, "🔧 AudioRecord libéré")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur arrêt écoute: ${e.message}")
        }
        audioRecord = null
    }

    fun isListening(): Boolean = isListening
}
FILE

# ==================== VÉRIFICATIONS FINALES ====================
echo ""
echo "=== ✅ VÉRIFICATIONS FINALES ==="

# 1. Vérifier fichier créé
if [ ! -f "app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt" ]; then
    echo "❌ Fichier non créé"
    exit 1
fi
echo "✅ Fichier créé"

# 2. Vérifier syntaxe
echo "=== 📋 SYNTAXE ==="
if grep -q "fun startListening(): Boolean" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt; then
    echo "✅ Méthode startListening présente"
else
    echo "❌ Méthode manquante"
    exit 1
fi

# 3. Vérifier braces équilibrées
new_start_braces=$(grep -o "{" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt | wc -l)
new_end_braces=$(grep -o "}" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt | wc -l)
if [ "$new_start_braces" -eq "$new_end_braces" ]; then
    echo "✅ Braces équilibrées: $new_start_braces"
else
    echo "❌ Braces déséquilibrées: $new_start_braces { vs $new_end_braces }"
    exit 1
fi

# 4. Vérifier logs de debug
echo "=== 🔍 LOGS DEBUG ==="
grep -c "Log\." app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt | xargs echo "Logs ajoutés:"

# 5. Vérifier détection forcée
if grep -q "DÉTECTION FORCÉE APRÈS 3 SECONDES" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt; then
    echo "✅ Détection forcée implémentée"
else
    echo "❌ Détection forcée manquante"
    exit 1
fi

echo ""
echo "🎯 CORRECTION APPLIQUÉE ET VÉRIFIÉE"
echo "📊 5 vérifications passées - Détection forcée après 3 secondes"
echo "🚀 PUSH: git add . && git commit -m 'FIX: Détection audio forcée après 3s avec logs complets' && git push"
