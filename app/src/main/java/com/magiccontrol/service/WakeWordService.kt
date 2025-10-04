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
import com.magiccontrol.utils.PreferencesManager

class WakeWordService : Service() {

    private var wakeWordDetector: WakeWordDetector? = null
    private val TAG = "WakeWordService"
    private var serviceStarted = false
    private var retryCount = 0
    private val maxRetries = 3

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service créé")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Démarrage service")
        
        if (serviceStarted) return START_STICKY

        try {
            // Vérification permission
            if (!hasMicrophonePermission()) {
                Log.e(TAG, "Permission microphone manquante")
                TTSManager.speak(applicationContext, "Permission microphone requise")
                return START_NOT_STICKY
            }
            
            startForegroundService()
            
            // 🎯 DÉLAI CRITIQUE: Laisser le système audio se préparer (1500ms)
            Handler(Looper.getMainLooper()).postDelayed({
                try {
                    initializeAudioDetector()
                    serviceStarted = true
                    Log.d(TAG, "✅ Service activé avec délai de sécurité")
                } catch (e: Exception) {
                    Log.e(TAG, "❌ Erreur initialisation différée", e)
                    handleServiceError()
                }
            }, 1500L)
            
        } catch (e: Exception) {
            Log.e(TAG, "Erreur démarrage", e)
            handleServiceError()
            return START_NOT_STICKY
        }

        return START_STICKY
    }

    private fun hasMicrophonePermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            android.Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun startForegroundService() {
        val keyword = PreferencesManager.getActivationKeyword(applicationContext)
        val language = PreferencesManager.getCurrentLanguage(applicationContext)
        
        val notification = NotificationCompat.Builder(this, "MAGIC_CONTROL")
            .setContentTitle("Magic Control Actif")
            .setContentText("Dites \"$keyword\" • ${language.uppercase()}")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setOngoing(true)
            .build()
        startForeground(1001, notification)
    }

    private fun initializeAudioDetector() {
        try {
            wakeWordDetector = WakeWordDetector(applicationContext)
            wakeWordDetector?.onWakeWordDetected = {
                onWakeWordDetected()
            }
            Handler(Looper.getMainLooper()).postDelayed({
                startListening()
            }, 1000L)
        } catch (e: Exception) {
            Log.e(TAG, "Erreur détecteur", e)
            throw e
        }
    }

    private fun startListening() {
        try {
            wakeWordDetector?.startListening()
            Log.d(TAG, "Écoute activée")
        } catch (e: Exception) {
            Log.e(TAG, "Erreur écoute", e)
            throw e
        }
    }

    private fun onWakeWordDetected() {
        Log.d(TAG, "Mot-clé détecté")
        TTSManager.speak(applicationContext, "Oui?")
        Handler(Looper.getMainLooper()).postDelayed({
            val intent = Intent(this, FullRecognitionService::class.java)
            startService(intent)
        }, 500L)
    }

    private fun handleServiceError() {
        if (retryCount < maxRetries) {
            retryCount++
            Log.w(TAG, "Retry $retryCount/$maxRetries")
            Handler(Looper.getMainLooper()).postDelayed({
                initializeAudioDetector()
            }, 2000L)
        } else {
            Log.e(TAG, "Échec définitif")
            TTSManager.speak(applicationContext, "Service défaillant")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Service arrêté")
        wakeWordDetector?.stopListening()
        serviceStarted = false
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
