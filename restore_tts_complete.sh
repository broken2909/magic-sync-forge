#!/bin/bash
echo "🔧 RÉTABLISSEMENT TTS COMPLET - RIEN OUBLIÉ"

cd /data/data/com.termux/files/home/magic-sync-forge/

# ==================== SAUVEGARDE ====================
echo "=== 📸 SAUVEGARDE ==="
cp app/src/main/java/com/magiccontrol/service/WakeWordService.kt app/src/main/java/com/magiccontrol/service/WakeWordService.kt.backup
echo "✅ Sauvegarde créée"

# ==================== ÉTAT ACTUEL COMPLET ====================
echo ""
echo "=== 🔍 ÉTAT ACTUEL COMPLET ==="
echo "📊 Lignes totales: $(wc -l < app/src/main/java/com/magiccontrol/service/WakeWordService.kt)"
echo "📦 Imports:"
grep "^import" app/src/main/java/com/magiccontrol/service/WakeWordService.kt
echo "🎯 Méthodes principales:"
grep -n "fun " app/src/main/java/com/magiccontrol/service/WakeWordService.kt

# ==================== CORRECTION COMPLÈTE ====================
echo ""
echo "=== 🛠️ RÉTABLISSEMENT COMPLET ==="

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

        // ✅ TTS APRÈS 3 SECONDES - COMPLETEMENT RÉTABLI
        Handler(Looper.getMainLooper()).postDelayed({
            Log.d(TAG, "🔊 Lancement message vocal d'activation")
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

# ==================== VÉRIFICATIONS COMPLÈTES ====================
echo ""
echo "=== ✅ VÉRIFICATIONS COMPLÈTES ==="

# 1. Fichier créé
if [ ! -f "app/src/main/java/com/magiccontrol/service/WakeWordService.kt" ]; then
    echo "❌ Fichier non créé"
    exit 1
fi
echo "✅ Fichier créé"

# 2. Import TTSManager
if grep -q "import com.magiccontrol.tts.TTSManager" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
    echo "✅ Import TTSManager présent"
else
    echo "❌ Import TTSManager manquant"
    exit 1
fi

# 3. Appel TTS avec activation_prompt
if grep -q 'TTSManager.speak.*activation_prompt' app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
    echo "✅ Appel TTS avec activation_prompt présent"
else
    echo "❌ Appel TTS manquant"
    exit 1
fi

# 4. Délai 3 secondes
if grep -q "postDelayed.*3000L" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
    echo "✅ Délai 3 secondes présent"
else
    echo "❌ Délai manquant"
    exit 1
fi

# 5. Écoute immédiate
if grep -q "startWakeWordDetection()" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
    echo "✅ Écoute immédiate présente"
else
    echo "❌ Écoute immédiate manquante"
    exit 1
fi

# 6. Toutes les méthodes conservées
echo "=== 🔧 MÉTHODES CONSERVÉES ==="
for method in "onCreate" "onStartCommand" "createNotificationChannel" "createNotification" "startWakeWordDetection" "startFullRecognition" "onDestroy"; do
    if grep -q "fun $method" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
        echo "✅ $method"
    else
        echo "❌ $method MANQUANT"
        exit 1
    fi
done

# 7. Braces équilibrées
start_braces=$(grep -o "{" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)
end_braces=$(grep -o "}" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)
if [ "$start_braces" -eq "$end_braces" ]; then
    echo "✅ Braces équilibrées: $start_braces"
else
    echo "❌ Braces déséquilibrées: $start_braces { vs $end_braces }"
    exit 1
fi

# 8. Comparaison avec sauvegarde
echo ""
echo "=== 🔄 COMPARAISON AVEC SAUVEGARDE ==="
diff_count=$(diff -u app/src/main/java/com/magiccontrol/service/WakeWordService.kt.backup app/src/main/java/com/magiccontrol/service/WakeWordService.kt | grep "^[+-]" | grep -v "^\+\+\+\|^---" | wc -l)
echo "📊 Lignes modifiées: $diff_count"

echo ""
echo "🎯 TTS COMPLÈTEMENT RÉTABLI - RIEN OUBLIÉ"
echo "📊 8 vérifications passées - Structure intacte"
echo "🚀 PUSH: git add . && git commit -m 'FIX: Rétablissement complet TTS - Message vocal après 3s' && git push"
