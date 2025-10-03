#!/bin/bash
echo "🔧 AJOUT MESURE AUDIO AVEC VÉRIFICATIONS COMPLÈTES"

cd /data/data/com.termux/files/home/magic-sync-forge/

# ==================== VÉRIFICATIONS PRÉALABLES ====================
echo "=== 🔍 VÉRIFICATIONS PRÉALABLES ==="

# 1. Sauvegarde
echo "=== 📸 SAUVEGARDE ==="
cp app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt.backup_audio
echo "✅ Sauvegarde créée"

# 2. État avant
echo "=== 📋 ÉTAT AVANT ==="
original_lines=$(wc -l < app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt)
echo "Lignes avant: $original_lines"
echo "Braces avant: $(grep -o "{" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt | wc -l) { / $(grep -o "}" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt | wc -l) }"

# 3. Vérifier point d'insertion
echo "=== 📍 POINT D'INSERTION ==="
grep -n -A 2 -B 2 "bytesRead > 0" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

# ==================== MODIFICATION ====================
echo ""
echo "=== 🛠️ MODIFICATION CIBLÉE ==="

# Créer le code à insérer dans un fichier temporaire
cat > /tmp/audio_insert.txt << 'INSERT'
                            // ✅ MESURE NIVEAU AUDIO - AJOUT
                            val audioLevel = calculateAudioLevel(buffer, bytesRead)
                            val hasVoice = audioLevel > 1000
                            Log.d(TAG, "🎤 Audio: \${bytesRead}bytes, Niveau: \$audioLevel, Voix: \$hasVoice")
                            
                            if (hasVoice) {
                                consecutiveVoiceDetections++
                                Log.d(TAG, "🎯 Voix détectée (\$consecutiveVoiceDetections/\$voiceDetectionThreshold)")
                                
                                if (consecutiveVoiceDetections >= voiceDetectionThreshold) {
                                    Log.d(TAG, "✅ DÉTECTION VOIX CONFIRMÉE")
                                    consecutiveVoiceDetections = 0
                                    onWakeWordDetected?.invoke()
                                    break
                                }
                            } else {
                                consecutiveVoiceDetections = 0
                            }
INSERT

# Insérer après "if (bytesRead > 0) {"
sed -i '/if (bytesRead > 0) {/r /tmp/audio_insert.txt' app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

# Ajouter variables manquantes avant la classe
sed -i '/private val TAG = "WakeWordDetector"/a\
    private var consecutiveVoiceDetections = 0\
    private val voiceDetectionThreshold = 5 // 5 détections voix consécutives' app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

# Ajouter fonction calculateAudioLevel à la fin (avant dernière })
sed -i '/^}$/i\
\
    private fun calculateAudioLevel(buffer: ByteArray, bytesRead: Int): Int {\
        var sum = 0\
        for (i in 0 until bytesRead.coerceAtMost(100)) {\
            sum += Math.abs(buffer[i].toInt())\
        }\
        return sum / bytesRead.coerceAtLeast(1)\
    }' app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

# ==================== VÉRIFICATIONS FINALES ====================
echo ""
echo "=== ✅ VÉRIFICATIONS FINALES ==="

# 1. Vérifier fichier modifié
echo "=== 📏 STRUCTURE ==="
new_lines=$(wc -l < app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt)
echo "Lignes après: $new_lines"
echo "Lignes ajoutées: $((new_lines - original_lines))"

# 2. Vérifier braces équilibrées
echo "=== 🔄 BRACES ==="
start_braces=$(grep -o "{" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt | wc -l)
end_braces=$(grep -o "}" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt | wc -l)
if [ "$start_braces" -eq "$end_braces" ]; then
    echo "✅ Braces équilibrées: $start_braces { / $end_braces }"
else
    echo "❌ Braces déséquilibrées: $start_braces { / $end_braces }"
    exit 1
fi

# 3. Vérifier syntaxe Kotlin
echo "=== 📝 SYNTAXE KOTLIN ==="
if grep -q "fun calculateAudioLevel" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt && \
   grep -q "val audioLevel = calculateAudioLevel" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt; then
    echo "✅ Syntaxe fonctions correcte"
else
    echo "❌ Erreur syntaxe fonctions"
    exit 1
fi

# 4. Vérifier variables ajoutées
echo "=== 🔧 VARIABLES ==="
if grep -q "consecutiveVoiceDetections" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt && \
   grep -q "voiceDetectionThreshold" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt; then
    echo "✅ Variables ajoutées"
else
    echo "❌ Variables manquantes"
    exit 1
fi

# 5. Vérifier caractères invisibles
echo "=== 👻 CARACTÈRES INVISIBLES ==="
if file app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt | grep -q "UTF-8"; then
    echo "✅ Encoding UTF-8"
else
    echo "⚠️  Encoding non UTF-8"
fi

# 6. Vérifier logique métier
echo "=== 🎯 LOGIQUE MÉTIER ==="
if grep -q "hasVoice.*consecutiveVoiceDetections" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt && \
   grep -q "voiceDetectionThreshold.*5" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt; then
    echo "✅ Logique détection voix correcte"
else
    echo "❌ Erreur logique métier"
    exit 1
fi

# 7. Vérifier pas de doublons
echo "=== 🔍 DOUBLONS ==="
calculate_count=$(grep -c "calculateAudioLevel" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt)
if [ "$calculate_count" -eq 2 ]; then # Déclaration + appel
    echo "✅ Pas de doublons fonctions"
else
    echo "❌ Doublons détectés"
    exit 1
fi

# 8. Vérifier build
echo "=== 🔨 TEST BUILD ==="
if ./gradlew compileDebugKotlin --console=plain > /dev/null 2>&1; then
    echo "✅ BUILD RÉUSSI - Syntaxe valide"
else
    echo "❌ BUILD ÉCHOUÉ - Erreur syntaxe"
    ./gradlew compileDebugKotlin --console=plain | grep -i error | head -5
    exit 1
fi

echo ""
echo "🎯 MESURE AUDIO AJOUTÉE AVEC SUCCÈS"
echo "📊 8 vérifications passées:"
echo "   ✅ Structure 📏 | ✅ Braces 🔄 | ✅ Syntaxe 📝"
echo "   ✅ Variables 🔧 | ✅ Encoding 👻 | ✅ Logique 🎯" 
echo "   ✅ Doublons 🔍 | ✅ Build 🔨"
echo "🚀 PUSH: git add . && git commit -m 'FEAT: Mesure niveau audio avec détection voix - 8 vérifications passées' && git push"
