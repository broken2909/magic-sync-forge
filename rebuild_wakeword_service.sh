#!/bin/bash
cd /data/data/com.termux/files/home/magic-sync-forge

echo "🎯 Début de la reconstruction méthodique..."

# Sauvegarde du fichier actuel
backup_dir="backup_reconstruction_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"
cp app/src/main/java/com/magiccontrol/service/WakeWordService.kt "$backup_dir/"

echo "📋 Création du nouveau fichier avec structure validée..."

# Reconstruction complète du fichier
cat > app/src/main/java/com/magiccontrol/service/WakeWordService.kt << 'KOTLIN'
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

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "🔄 WakeWordService onCreate()")
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "🚀 Démarrage du service vocal")
        
        if (serviceStarted) {
            Log.d(TAG, "⚠️ Service déjà actif")
            return START_STICKY
        }

        try {
            startForegroundService()
            initializeAudioDetector()
            serviceStarted = true
            Log.d(TAG, "✅ Service vocal activé avec succès")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur démarrage service", e)
            TTSManager.speak(applicationContext, "Erreur démarrage service vocal")
            return START_NOT_STICKY
        }

        return START_STICKY
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
            }
            
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
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

    private fun initializeAudioDetector() {
        try {
            Log.d(TAG, "🎯 Initialisation du détecteur audio...")
            
            wakeWordDetector = WakeWordDetector(applicationContext)
            
            wakeWordDetector?.onWakeWordDetected = {
                Log.d(TAG, "🎉 MOT-CLÉ DÉTECTÉ!")
                onWakeWordDetected()
            }

            // Délai avant démarrage de l'écoute
            Handler(Looper.getMainLooper()).postDelayed({
                startListening()
            }, 1000L)
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur initialisation détecteur", e)
            TTSManager.speak(applicationContext, "Erreur initialisation microphone")
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
        Log.d(TAG, "🎯 Traitement du mot-clé détecté")
        
        try {
            // 1. Feedback vocal immédiat
            TTSManager.speak(applicationContext, "Oui?")
            
            // 2. Arrêt de l'écoute actuelle
            wakeWordDetector?.stopListening()
            
            // 3. Lancement du service de reconnaissance complète
            Handler(Looper.getMainLooper()).postDelayed({
                val intent = Intent(this, FullRecognitionService::class.java)
                startService(intent)
                Log.d(TAG, "🚀 FullRecognitionService démarré")
            }, 1000L)
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur traitement mot-clé", e)
        }
    }

    private fun hasMicrophonePermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            android.Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "🛑 Arrêt du service vocal")
        
        try {
            wakeWordDetector?.stopListening()
            wakeWordDetector = null
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur nettoyage détecteur", e)
        }
        
        serviceStarted = false
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
KOTLIN

echo "✅ Nouveau fichier créé"

# Vérifications immédiates
echo ""
echo "🔍 VÉRIFICATIONS IMMÉDIATES"
echo "==========================="

# Vérification 1: Braces équilibrées
echo "📋 Vérification des braces..."
open_braces=$(grep -o "{" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)
close_braces=$(grep -o "}" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)

if [ "$open_braces" -eq "$close_braces" ]; then
    echo "✅ Braces équilibrées: $open_braces/{ $close_braces/}"
else
    echo "❌ Braces déséquilibrées: $open_braces/{ $close_braces/}"
    exit 1
fi

# Vérification 2: Structure Kotlin de base
echo "📋 Vérification structure Kotlin..."
if grep -q "class WakeWordService" app/src/main/java/com/magiccontrol/service/WakeWordService.kt && \
   grep -q "override fun onBind" app/src/main/java/com/magiccontrol/service/WakeWordService.kt && \
   grep -q "private val TAG" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
    echo "✅ Structure Kotlin valide"
else
    echo "❌ Structure Kotlin problématique"
    exit 1
fi

# Vérification 3: Encodage UTF-8
echo "📋 Vérification encodage..."
if file -i app/src/main/java/com/magiccontrol/service/WakeWordService.kt | grep -q "utf-8"; then
    echo "✅ Encodage UTF-8 correct"
else
    echo "❌ Problème d'encodage"
    exit 1
fi

# Vérification 4: Syntaxe Kotlin basique
echo "📋 Vérification syntaxe Kotlin..."
if ! grep -q "fun ()" app/src/main/java/com/magiccontrol/service/WakeWordService.kt && \
   ! grep -q "override fun ()" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
    echo "✅ Aucune fonction sans nom détectée"
else
    echo "❌ Fonctions sans nom détectées"
    exit 1
fi

echo ""
echo "🎉 RECONSTRUCTION TERMINÉE AVEC SUCCÈS !"
echo "📍 Sauvegarde dans: $backup_dir"

