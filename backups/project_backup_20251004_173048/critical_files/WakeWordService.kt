package com.magiccontrol.service

import android.app.*
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.*
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.magiccontrol.MainActivity
import com.magiccontrol.tts.TTSManager
import com.magiccontrol.utils.PreferencesManager

/**
 * Service unifié utilisant ConversationManager
 * Gère à la fois la détection et l'interaction
 */
class WakeWordService : Service() {

    private val TAG = "WakeWordService"
    private val NOTIFICATION_ID = 1001
    private val CHANNEL_ID = "MAGIC_CONTROL_CHANNEL"
    
    // Composants audio
    private var audioRecord: AudioRecord? = null
    private var isListening = false
    private val sampleRate = 16000
    private val bufferSize = 8192
    
    // Gestionnaire de conversation
    private var conversationManager: ConversationManager? = null
    
    // Thread de traitement audio
    private var audioThread: Thread? = null

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "🎯 Service conversation créé")
        createNotificationChannel()
        conversationManager = ConversationManager(applicationContext)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "🚀 Démarrage service conversation")
        
        // Vérification permission microphone
        if (!hasMicrophonePermission()) {
            Log.e(TAG, "❌ Permission microphone manquante")
            TTSManager.speak(applicationContext, "Permission microphone requise")
            return START_NOT_STICKY
        }
        
        // Démarrer en foreground
        startForegroundService()
        
        // Démarrer l'écoute
        startAudioListening()
        
        Log.d(TAG, "✅ Service conversation activé")
        return START_STICKY
    }
    
    private fun hasMicrophonePermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            android.Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Magic Control Voice Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Service de reconnaissance vocale Magic Control"
                setShowBadge(false)
                setSound(null, null)
                enableLights(false)
                enableVibration(false)
            }
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager?.createNotificationChannel(channel)
        }
    }
    
    private fun startForegroundService() {
        val keyword = PreferencesManager.getActivationKeyword(applicationContext)
        val language = PreferencesManager.getCurrentLanguage(applicationContext)
        
        val notificationIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("🎤 Magic Control Actif")
            .setContentText("Dites '$keyword' • ${language.uppercase()}")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setShowWhen(false)
            .setSilent(true)
            .build()
        
        startForeground(NOTIFICATION_ID, notification)
        Log.d(TAG, "📱 Notification foreground activée")
    }
    
    private fun startAudioListening() {
        try {
            val minBufferSize = AudioRecord.getMinBufferSize(
                sampleRate,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT
            )

            if (minBufferSize == AudioRecord.ERROR || minBufferSize == AudioRecord.ERROR_BAD_VALUE) {
                Log.e(TAG, "❌ Configuration audio invalide")
                return
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
                return
            }

            audioRecord?.startRecording()

            if (audioRecord?.recordingState != AudioRecord.RECORDSTATE_RECORDING) {
                Log.e(TAG, "❌ Enregistrement non démarré")
                return
            }

            isListening = true
            startAudioProcessingThread(finalBufferSize)

            Log.d(TAG, "✅ Écoute audio activée")

        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur démarrage audio", e)
        }
    }
    
    private fun startAudioProcessingThread(bufferSize: Int) {
        audioThread = Thread {
            Process.setThreadPriority(Process.THREAD_PRIORITY_URGENT_AUDIO)
            val buffer = ByteArray(bufferSize)

            Log.d(TAG, "🔊 Thread audio démarré")

            try {
                while (isListening && audioRecord != null) {
                    try {
                        val bytesRead = audioRecord?.read(buffer, 0, buffer.size) ?: 0

                        if (bytesRead > 0) {
                            // Simuler la détection VOSK (à intégrer avec le vrai VOSK)
                            processAudioWithConversationManager(buffer, bytesRead)
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
    
    /**
     * Traite l'audio via ConversationManager
     * (À ADAPTER avec la vraie intégration VOSK)
     */
    private fun processAudioWithConversationManager(buffer: ByteArray, bytesRead: Int) {
        try {
            conversationManager?.processAudio(buffer, bytesRead)
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur traitement conversation", e)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "🛑 Service conversation arrêté")
        
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
            audioRecord = null
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur arrêt audio", e)
        }
        
        try {
            conversationManager?.stop()
            conversationManager = null
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur arrêt conversation", e)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
