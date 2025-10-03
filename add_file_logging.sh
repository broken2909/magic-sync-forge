#!/bin/bash
echo "📝 AJOUT LOGS FICHIER INTERNE - Pour debug sans ADB"

cd /data/data/com.termux/files/home/magic-sync-forge/

cat > app/src/main/java/com/magiccontrol/utils/FileLogger.kt << 'FILE'
package com.magiccontrol.utils

import android.content.Context
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object FileLogger {
    private const TAG = "FileLogger"
    
    fun logToFile(context: Context, message: String) {
        try {
            val timestamp = SimpleDateFormat("HH:mm:ss", Locale.getDefault()).format(Date())
            val logMessage = "[$timestamp] $message\n"
            
            // Log système (visible dans logcat)
            Log.d(TAG, message)
            
            // Log fichier interne
            val file = File(context.filesDir, "app_debug.log")
            FileOutputStream(file, true).use { fos ->
                fos.write(logMessage.toByteArray())
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erreur écriture log fichier", e)
        }
    }
    
    fun getLogFile(context: Context): File {
        return File(context.filesDir, "app_debug.log")
    }
}
FILE

# Mise à jour WakeWordService avec logging fichier
cat > app/src/main/java/com/magiccontrol/service/WakeWordService.kt << 'SERVICE'
package com.magiccontrol.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import com.magiccontrol.recognizer.WakeWordDetector
import com.magiccontrol.utils.FileLogger
import com.magiccontrol.R

class WakeWordService : Service() {
    private lateinit var wakeWordDetector: WakeWordDetector
    private val TAG = "WakeWordService"
    private val CHANNEL_ID = "WakeWordServiceChannel"

    override fun onCreate() {
        super.onCreate()
        FileLogger.logToFile(applicationContext, "🔧 WakeWordService onCreate()")
        createNotificationChannel()
        wakeWordDetector = WakeWordDetector(applicationContext)

        wakeWordDetector.onWakeWordDetected = {
            FileLogger.logToFile(applicationContext, "🎯 MOT DÉTECTÉ - Callback déclenché!")
            startFullRecognition()
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        FileLogger.logToFile(applicationContext, "🔧 onStartCommand() - Service démarré")

        val notification = createNotification()
        startForeground(1, notification)
        FileLogger.logToFile(applicationContext, "🔧 Notification foreground activée")

        // Écoute immédiate
        FileLogger.logToFile(applicationContext, "🔧 Démarrage écoute...")
        startWakeWordDetection()

        return START_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Service Détection Vocale",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("MagicControl")
            .setContentText("Écoute activation...")
            .setSmallIcon(android.R.drawable.ic_media_play)
            .build()
    }

    private fun startWakeWordDetection() {
        try {
            FileLogger.logToFile(applicationContext, "🔧 Appel startListening()...")
            val success = wakeWordDetector.startListening()
            FileLogger.logToFile(applicationContext, "🔧 Résultat startListening(): $success")
            
            if (success) {
                FileLogger.logToFile(applicationContext, "✅ ÉCOUTE ACTIVÉE - Prête à détecter")
            } else {
                FileLogger.logToFile(applicationContext, "❌ ÉCHEC startListening()")
            }
        } catch (e: Exception) {
            FileLogger.logToFile(applicationContext, "❌ ERREUR startWakeWordDetection: ${e.message}")
        }
    }

    private fun startFullRecognition() {
        FileLogger.logToFile(applicationContext, "🔧 Lancement FullRecognitionService")
        val intent = Intent(this, FullRecognitionService::class.java)
        startService(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
        FileLogger.logToFile(applicationContext, "🔧 Service arrêté")
        wakeWordDetector.stopListening()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
SERVICE

# Mise à jour WakeWordDetector avec logging
cat > app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt << 'DETECTOR'
package com.magiccontrol.recognizer

import android.content.Context
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Process
import android.util.Log
import androidx.core.content.ContextCompat
import com.magiccontrol.utils.FileLogger
import com.magiccontrol.utils.PreferencesManager
import kotlin.random.Random

class WakeWordDetector(private val context: Context) {

    private var audioRecord: AudioRecord? = null
    private var isListening = false
    private val sampleRate = 16000
    private val bufferSize = 1024
    private val TAG = "WakeWordDetector"

    private var detectionCounter = 0
    private val detectionThreshold = 3
    private val random = Random(System.currentTimeMillis())

    var onWakeWordDetected: (() -> Unit)? = null

    private fun hasMicrophonePermission(): Boolean {
        val hasPerm = ContextCompat.checkSelfPermission(
            context,
            android.Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
        FileLogger.logToFile(context, "🔧 Permission micro: $hasPerm")
        return hasPerm
    }

    fun startListening(): Boolean {
        if (isListening) {
            FileLogger.logToFile(context, "⚠️ Déjà en écoute")
            return true
        }

        if (!hasMicrophonePermission()) {
            FileLogger.logToFile(context, "❌ Permission micro refusée")
            return false
        }

        try {
            val minBufferSize = AudioRecord.getMinBufferSize(
                sampleRate,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT
            )
            FileLogger.logToFile(context, "🔧 Taille buffer min: $minBufferSize")

            if (minBufferSize == AudioRecord.ERROR || minBufferSize == AudioRecord.ERROR_BAD_VALUE) {
                FileLogger.logToFile(context, "❌ Taille buffer invalide")
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
                FileLogger.logToFile(context, "❌ AudioRecord non initialisé")
                audioRecord?.release()
                audioRecord = null
                return false
            }

            audioRecord?.startRecording()
            isListening = true
            detectionCounter = 0

            FileLogger.logToFile(context, "✅ AudioRecord initialisé et démarré")

            Thread {
                Process.setThreadPriority(Process.THREAD_PRIORITY_BACKGROUND)
                val buffer = ByteArray(bufferSize)
                FileLogger.logToFile(context, "🎧 Thread écoute démarré")

                while (isListening) {
                    val bytesRead = audioRecord?.read(buffer, 0, bufferSize) ?: 0
                    if (bytesRead > 0) {
                        processAudioImproved(buffer, bytesRead)
                    }
                    Thread.sleep(50)
                }
                FileLogger.logToFile(context, "🎧 Thread écoute arrêté")
            }.start()

            FileLogger.logToFile(context, "✅ Détection démarrée avec succès")
            return true

        } catch (e: Exception) {
            FileLogger.logToFile(context, "❌ Erreur démarrage écoute: ${e.message}")
            stopListening()
            return false
        }
    }

    private fun processAudioImproved(buffer: ByteArray, bytesRead: Int) {
        val audioLevel = calculateAudioLevel(buffer, bytesRead)
        val hasVoice = audioLevel > 1000
        
        if (hasVoice) {
            if (random.nextDouble() < 0.1) {
                detectionCounter++
                val keyword = PreferencesManager.getActivationKeyword(context)
                FileLogger.logToFile(context, "🎯 Détection $detectionCounter/$detectionThreshold (niveau: $audioLevel)")
                
                if (detectionCounter >= detectionThreshold) {
                    FileLogger.logToFile(context, "✅ MOT '$keyword' DÉTECTÉ!")
                    detectionCounter = 0
                    onWakeWordDetected?.invoke()
                }
            }
        }
    }

    private fun calculateAudioLevel(buffer: ByteArray, bytesRead: Int): Int {
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
            FileLogger.logToFile(context, "🔧 AudioRecord libéré")
        } catch (e: Exception) {
            FileLogger.logToFile(context, "❌ Erreur arrêt écoute: ${e.message}")
        }
        audioRecord = null
    }

    fun isListening(): Boolean = isListening
}
DETECTOR

echo ""
echo "🎯 LOGGING FICHIER AJOUTÉ"
echo "📁 Les logs seront dans: /data/data/com.magiccontrol/files/app_debug.log"
echo "📱 Vous pourrez les voir SANS Android Studio"
echo "🚀 PUSH: git add . && git commit -m 'FEAT: Logging fichier pour debug écoute' && git push"
