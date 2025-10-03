package com.magiccontrol.service

import android.app.*
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.IBinder
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.magiccontrol.MainActivity
import com.magiccontrol.recognizer.WakeWordDetector
import com.magiccontrol.tts.TTSManager
import com.magiccontrol.R
import com.magiccontrol.utils.PreferencesManager

class WakeWordService : Service() {

    private var wakeWordDetector: WakeWordDetector? = null
    private val TAG = "WakeWordService"
    private val NOTIFICATION_ID = 1001
    private val CHANNEL_ID = "MAGIC_CONTROL_CHANNEL"
    private var serviceStarted = false
    private var retryCount = 0
    private val maxRetries = 3

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "🚀 WakeWordService onCreate()")
        
        try {
            createNotificationChannel()
            
            if (!hasMicrophonePermission()) {
                Log.e(TAG, "❌ Permission microphone manquante")
                TTSManager.speak(applicationContext, "Permission microphone requise")
                stopSelf()
                return
            }
            
            Log.d(TAG, "✅ Permissions OK, initialisation détecteur...")
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur onCreate", e)
            stopSelf()
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "🔊 WakeWordService onStartCommand()")
        
        try {
            if (serviceStarted) {
                Log.d(TAG, "⚠️ Service déjà actif")
                return START_STICKY
            }
            
            startForegroundService()
            initializeAudioDetector()
            
            serviceStarted = true
            retryCount = 0
            
            Log.d(TAG, "✅ WakeWordService démarré avec succès")
            return START_STICKY
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur onStartCommand", e)
            handleServiceError("Erreur démarrage service")
            return START_NOT_STICKY
        }
    }
    
    private fun hasMicrophonePermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            android.Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
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
                
                Log.d(TAG, "📢 Canal notification créé")
            } catch (e: Exception) {
                Log.e(TAG, "❌ Erreur création canal", e)
            }
        }
    }
    
    private fun startForegroundService() {
        try {
            val notificationIntent = Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            
            val pendingIntent = PendingIntent.getActivity(
                this, 0, notificationIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            val keyword = PreferencesManager.getActivationKeyword(applicationContext)
            val language = PreferencesManager.getCurrentLanguage(applicationContext)
            
            val notification = NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("🎤 Magic Control Actif")
                .setContentText("Micro activé • Dites '$keyword' • ${language.uppercase()}")
                .setSmallIcon(android.R.drawable.ic_btn_speak_now)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setCategory(NotificationCompat.CATEGORY_SERVICE)
                .setShowWhen(false)
                .setSilent(true)
                .build()
            
            startForeground(NOTIFICATION_ID, notification)
            Log.d(TAG, "🔔 Service foreground démarré")
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur foreground service", e)
            throw e
        }
    }
    
    private fun initializeAudioDetector() {
        try {
            Log.d(TAG, "🎯 Initialisation détecteur audio...")
            
            wakeWordDetector?.cleanup()
            
            wakeWordDetector = WakeWordDetector(applicationContext)
            
            wakeWordDetector?.onWakeWordDetected = {
                Log.d(TAG, "🎉 MOT-CLÉ DÉTECTÉ!")
                onWakeWordDetected()
            }
            
            Handler(Looper.getMainLooper()).postDelayed({
                startListening()
            }, 2000L)
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur initialisation détecteur", e)
            handleServiceError("Erreur micro")
        }
    }
    
    private fun startListening() {
        try {
            val detector = wakeWordDetector
            if (detector == null) {
                Log.e(TAG, "❌ Détecteur null")
                handleServiceError("Détecteur audio non disponible")
                return
            }
            
            Log.d(TAG, "🎧 Démarrage écoute...")
            val success = detector.startListening()
            
            if (success) {
                val keyword = PreferencesManager.getActivationKeyword(applicationContext)
                Log.d(TAG, "✅ Écoute active pour mot-clé: '$keyword'")
                
                updateNotification("🎧 Écoute active • Dites '$keyword'")
                
                Handler(Looper.getMainLooper()).postDelayed({
                    TTSManager.speak(applicationContext, "Magic Control activé. Dites $keyword pour commander.")
                }, 500L)
                
            } else {
                Log.e(TAG, "❌ Échec démarrage écoute")
                handleServiceError("Impossible d'activer le micro")
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur démarrage écoute", e)
            handleServiceError("Erreur démarrage micro")
        }
    }
    
    private fun onWakeWordDetected() {
        Log.d(TAG, "🎯 Traitement mot-clé détecté")
        
        try {
            TTSManager.speak(applicationContext, "Oui?")
            
            updateNotification("🎯 Mot-clé détecté • Traitement...")
            
            Handler(Looper.getMainLooper()).postDelayed({
                val intent = Intent(this, FullRecognitionService::class.java)
                startService(intent)
                Log.d(TAG, "🚀 FullRecognitionService lancé")
            }, 1000L)
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur traitement mot-clé", e)
        }
    }
    
    private fun updateNotification(message: String) {
        try {
            val notificationManager = getSystemService(NotificationManager::class.java)
            
            val notification = NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("🎤 Magic Control Actif")
                .setContentText(message)
                .setSmallIcon(android.R.drawable.ic_btn_speak_now)
                .setOngoing(true)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setShowWhen(false)
                .setSilent(true)
                .build()
            
            notificationManager?.notify(NOTIFICATION_ID, notification)
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur mise à jour notification", e)
        }
    }
    
    private fun handleServiceError(errorMessage: String) {
        Log.e(TAG, "🚨 Erreur service: $errorMessage")
        
        if (retryCount < maxRetries) {
            retryCount++
            Log.w(TAG, "🔄 Tentative de récupération $retryCount/$maxRetries")
            
            Handler(Looper.getMainLooper()).postDelayed({
                try {
                    initializeAudioDetector()
                } catch (e: Exception) {
                    Log.e(TAG, "❌ Échec récupération", e)
                }
            }, 2000L)
            
        } else {
            Log.e(TAG, "💀 Échec définitif service")
            TTSManager.speak(applicationContext, "Service Magic Control défaillant")
            stopSelf()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "🛑 WakeWordService onDestroy()")
        
        serviceStarted = false
        
        try {
            wakeWordDetector?.cleanup()
            wakeWordDetector = null
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur cleanup détecteur", e)
        }
        
        try {
            TTSManager.speak(applicationContext, "Magic Control désactivé")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur TTS arrêt", e)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
