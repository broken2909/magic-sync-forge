#!/bin/bash
echo "🔧 CORRECTION VÉRIFIÉE - Délai TTS"

cd /data/data/com.termux/files/home/magic-sync-forge/

# ==================== VÉRIFICATIONS PRÉALABLES ====================
echo "=== 🔍 VÉRIFICATIONS PRÉALABLES ==="

# 1. Vérifier fichier existe
if [ ! -f "app/src/main/java/com/magiccontrol/service/WakeWordService.kt" ]; then
    echo "❌ Fichier WakeWordService.kt manquant"
    exit 1
fi
echo "✅ Fichier présent"

# 2. Vérifier syntaxe actuelle
echo "=== 📋 CONTENU ACTUEL (extrait) ==="
grep -A 5 -B 5 "postDelayed" app/src/main/java/com/magiccontrol/service/WakeWordService.kt

# 3. Vérifier structure braces
start_braces=$(grep -o "{" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)
end_braces=$(grep -o "}" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)
if [ "$start_braces" -ne "$end_braces" ]; then
    echo "❌ Braces déséquilibrées: $start_braces { vs $end_braces }"
    exit 1
fi
echo "✅ Braces équilibrées: $start_braces"

# ==================== CRÉATION FICHIER CORRIGÉ ====================
echo ""
echo "=== 🛠️ CRÉATION FICHIER CORRIGÉ ==="

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

        // ✅ CORRECTION: Écoute IMMÉDIATE
        startWakeWordDetection()

        // ✅ TTS après 3s SANS bloquer l'écoute
        Handler(Looper.getMainLooper()).postDelayed({
            TTSManager.speak(applicationContext, applicationContext.getString(R.string.activation_prompt))
        }, 3000L)

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
echo "✅ Fichier créé"

# 2. Vérifier syntaxe modifications
echo "=== 📋 MODIFICATIONS APPLIQUÉES ==="
grep -A 3 -B 3 "startWakeWordDetection()" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | head -10

# 3. Vérifier braces équilibrées
new_start_braces=$(grep -o "{" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)
new_end_braces=$(grep -o "}" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)
if [ "$new_start_braces" -ne "$new_end_braces" ]; then
    echo "❌ Braces déséquilibrées après modification"
    exit 1
fi
echo "✅ Braces équilibrées après modification: $new_start_braces"

# 4. Vérifier encoding
if ! file app/src/main/java/com/magiccontrol/service/WakeWordService.kt | grep -q "UTF-8"; then
    echo "⚠️  Encoding non UTF-8 détecté"
fi

echo ""
echo "🎯 CORRECTION APPLIQUÉE AVEC SUCCÈS"
echo "📊 Résumé: Écoute immédiate + TTS après 3s (non bloquant)"
echo "🚀 PUSH: git add . && git commit -m 'FIX: Écoute immédiate sans blocage TTS' && git push"
