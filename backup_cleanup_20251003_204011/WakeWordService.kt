package com.magiccontrol.service

import android.app.*
import android.content.Intent
import android.content.pm.PackageManager
import android.os.*
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

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "🚀 Service audio créé")
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "🔊 Démarrage service audio")
        
        if (serviceStarted) {
            Log.d(TAG, "⚠️ Service déjà actif")
            return START_STICKY
        }
        
        try {
            // Démarrer en foreground IMMÉDIATEMENT
            startForegroundService()
            
            // Initialiser détecteur
            initializeAudioDetector()
            
            serviceStarted = true
            Log.d(TAG, "✅ Service audio ACTIF")
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur démarrage audio", e)
            TTSManager.speak(applicationContext, "Erreur microphone")
        }
        
        return START_STICKY
    }
    
    private fun startForegroundService() {
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("🎤 Magic Control Actif")
            .setContentText("Micro prêt - Dites 'Magic'")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
        
        startForeground(NOTIFICATION_ID, notification)
        Log.d(TAG, "📱 Notification foreground activée")
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Magic Control Voice",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Service reconnaissance vocale"
                setShowBadge(false)
            }
            
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }
    
    private fun initializeAudioDetector() {
        try {
            Log.d(TAG, "🎯 Initialisation détecteur audio...")
            
            wakeWordDetector = WakeWordDetector(applicationContext)
            
            wakeWordDetector?.onWakeWordDetected = {
                Log.d(TAG, "🎉 MOT-CLÉ DÉTECTÉ!")
                onWakeWordDetected()
            }
            
            // Délai avant démarrage écoute
            Handler(Looper.getMainLooper()).postDelayed({
                startListening()
            }, 1000L)
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur init détecteur", e)
        }
    }
    
    private fun startListening() {
        try {
            val success = wakeWordDetector?.startListening() ?: false
            
            if (success) {
                Log.d(TAG, "👂 Écoute audio ACTIVÉE")
                TTSManager.speak(applicationContext, "Magic Control activé. Dites Magic pour commander.")
            } else {
                Log.e(TAG, "❌ Échec démarrage écoute")
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur démarrage écoute", e)
        }
    }
    
    private fun onWakeWordDetected() {
        Log.d(TAG, "🎯 Traitement mot-clé détecté")
        TTSManager.speak(applicationContext, "Oui?")
    stopListening()  # 🔧 ARRÊTER ÉCOUTE PENDANT TRAITEMENT
        
        // Lancer reconnaissance complète
        Handler(Looper.getMainLooper()).postDelayed({
            val intent = Intent(this, FullRecognitionService::class.java)
            startService(intent)
        }, 1000L)
    }
    
    private fun hasMicrophonePermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            android.Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "🛑 Service audio arrêté")
        
        try {
            wakeWordDetector?.stopListening()
            wakeWordDetector = null
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur cleanup", e)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
