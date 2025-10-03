#!/bin/bash
echo "🔧 RÉTABLISSEMENT TTS AVEC VÉRIFICATIONS"

cd /data/data/com.termux/files/home/magic-sync-forge/

# ==================== VÉRIFICATIONS PRÉALABLES ====================
echo "=== 🔍 ÉTAT ACTUEL WAKE WORDSERVICE ==="

# 1. Vérifier imports TTS
if grep -q "import.*TTSManager" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
    echo "✅ Import TTSManager présent"
else
    echo "❌ Import TTSManager MANQUANT"
fi

# 2. Vérifier appel TTS
if grep -q "TTSManager.speak" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
    echo "✅ Appel TTS présent"
else
    echo "❌ Appel TTS MANQUANT"
fi

# ==================== CORRECTION ====================
echo ""
echo "=== 🛠️ RÉTABLISSEMENT TTS ==="

# Créer version avec TTS rétabli
cat > app/src/main/java/com/magiccontrol/service/WakeWordService.kt << 'FILE'
package com.magiccontrol.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import com.magiccontrol.recognizer.WakeWordDetector
import com.magiccontrol.tts.TTSManager
import com.magiccontrol.R

class WakeWordService : Service() {
    private lateinit var wakeWordDetector: WakeWordDetector
    private val TAG = "WakeWordService"
    private val CHANNEL_ID = "WakeWordServiceChannel"

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service de détection créé")
        createNotificationChannel()
        wakeWordDetector = WakeWordDetector(applicationContext)

        wakeWordDetector.onWakeWordDetected = {
            Log.d(TAG, "Mot d activation détecté")
            startFullRecognition()
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Démarrage service détection")

        val notification = createNotification()
        startForeground(1, notification)

        // ✅ Écoute immédiate
        startWakeWordDetection()
        Log.d(TAG, "✅ Écoute IMMÉDIATEMENT activée")

        // ✅ RÉTABLISSEMENT TTS - Message après 2 secondes
        Handler(Looper.getMainLooper()).postDelayed({
            Log.d(TAG, "🔊 Lancement message TTS...")
            TTSManager.speak(applicationContext, applicationContext.getString(R.string.activation_prompt))
            Log.d(TAG, "🔊 Message TTS envoyé")
        }, 2000L)

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
            wakeWordDetector.startListening()
            Log.d(TAG, "Détection démarrée")
        } catch (e: Exception) {
            Log.e(TAG, "Erreur démarrage détection", e)
        }
    }

    private fun startFullRecognition() {
        val intent = Intent(this, FullRecognitionService::class.java)
        startService(intent)
        Log.d(TAG, "Reconnaissance démarrée")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Arrêt service détection")
        wakeWordDetector.stopListening()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
FILE

# ==================== VÉRIFICATIONS FINALES ====================
echo ""
echo "=== ✅ VÉRIFICATIONS FINALES ==="

# 1. Vérifier fichier créé
if [ ! -f "app/src/main/java/com/magiccontrol/service/WakeWordService.kt" ]; then
    echo "❌ Fichier non créé"
    exit 1
fi

# 2. Vérifier import TTS
if grep -q "import.*TTSManager" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
    echo "✅ Import TTSManager rétabli"
else
    echo "❌ Import TTSManager manquant"
    exit 1
fi

# 3. Vérifier appel TTS
if grep -q "TTSManager.speak.*activation_prompt" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
    echo "✅ Appel TTS rétabli"
else
    echo "❌ Appel TTS manquant"
    exit 1
fi

# 4. Vérifier délai
if grep -q "postDelayed.*2000L" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
    echo "✅ Délai TTS configuré (2 secondes)"
else
    echo "❌ Délai TTS manquant"
    exit 1
fi

# 5. Vérifier braces
start_braces=$(grep -o "{" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)
end_braces=$(grep -o "}" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)
if [ "$start_braces" -eq "$end_braces" ]; then
    echo "✅ Braces équilibrées: $start_braces"
else
    echo "❌ Braces déséquilibrées"
    exit 1
fi

echo ""
echo "🎯 TTS RÉTABLI ET VÉRIFIÉ"
echo "📊 5 vérifications passées - Message vocal activé après 2 secondes"
echo "🚀 PUSH: git add . && git commit -m 'FIX: Rétablissement TTS activation_prompt avec vérifications' && git push"
