#!/bin/bash
echo "🔧 CORRECTION INSERTION AUDIO"

cd /data/data/com.termux/files/home/magic-sync-forge/

# Restaurer la sauvegarde d'abord
cp app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt.backup_audio app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

echo "=== 🔍 DIAGNOSTIC ERREUR ==="
echo "Vérification /tmp:"
ls -la /tmp/ 2>/dev/null | head -5 || echo "❌ /tmp inaccessible"

# Créer le code à insérer DIRECTEMENT
echo "=== 🛠️ INSERTION DIRECTE ==="

# Insérer après "if (bytesRead > 0) {" - méthode robuste
sed -i '93a\                            // ✅ MESURE NIVEAU AUDIO - AJOUT\
                            val audioLevel = calculateAudioLevel(buffer, bytesRead)\
                            val hasVoice = audioLevel > 1000\
                            Log.d(TAG, "🎤 Audio: ${bytesRead}bytes, Niveau: $audioLevel, Voix: $hasVoice")\
                            \
                            if (hasVoice) {\
                                consecutiveVoiceDetections++\
                                Log.d(TAG, "🎯 Voix détectée ($consecutiveVoiceDetections/$voiceDetectionThreshold)")\
                                \
                                if (consecutiveVoiceDetections >= voiceDetectionThreshold) {\
                                    Log.d(TAG, "✅ DÉTECTION VOIX CONFIRMÉE")\
                                    consecutiveVoiceDetections = 0\
                                    onWakeWordDetected?.invoke()\
                                    break\
                                }\
                            } else {\
                                consecutiveVoiceDetections = 0\
                            }' app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

# Ajouter variables
sed -i '/private val TAG = "WakeWordDetector"/a\
    private var consecutiveVoiceDetections = 0\
    private val voiceDetectionThreshold = 5' app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

# Ajouter fonction
sed -i '/^}$/i\
\
    private fun calculateAudioLevel(buffer: ByteArray, bytesRead: Int): Int {\
        var sum = 0\
        for (i in 0 until bytesRead.coerceAtMost(100)) {\
            sum += Math.abs(buffer[i].toInt())\
        }\
        return sum / bytesRead.coerceAtLeast(1)\
    }' app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

echo "=== ✅ VÉRIFICATION RAPIDE ==="
echo "Fonction calculateAudioLevel:"
grep -n "calculateAudioLevel" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

echo "Appel calculateAudioLevel:"  
grep -n "val audioLevel = calculateAudioLevel" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

echo "Variables:"
grep -n "consecutiveVoiceDetections\\|voiceDetectionThreshold" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

echo ""
echo "🎯 CORRECTION APPLIQUÉE"
echo "📊 Vérifiez les lignes ci-dessus - Doit montrer déclaration ET appel"
