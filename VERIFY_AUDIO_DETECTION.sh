#!/bin/bash

echo "🔍 VÉRIFICATION FONCTION MESURE AUDIO"

PROJECT_DIR="/data/data/com.termux/files/home/magic-sync-forge"
cd "$PROJECT_DIR"

FILE="app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt"

echo "=== 📁 CONTENU DU FICHIER ==="
echo ""

echo "=== 🔍 RECHERCHE FONCTION calculateAudioLevel ==="
if grep -q "calculateAudioLevel" "$FILE"; then
    echo "✅ FONCTION TROUVÉE"
    grep -A 5 "calculateAudioLevel" "$FILE"
else
    echo "❌ FONCTION ABSENTE"
fi

echo ""
echo "=== 🔍 RECHERCHE DÉTECTION VOCALE ==="
if grep -q "consecutiveVoiceDetections" "$FILE"; then
    echo "✅ LOGIQUE DÉTECTION TROUVÉE"
    grep -B 2 -A 5 "consecutiveVoiceDetections" "$FILE"
else
    echo "❌ LOGIQUE DÉTECTION ABSENTE"
fi

echo ""
echo "=== 🔍 RECHERCHE SEUIL AUDIO ==="
if grep -q "audioLevel >" "$FILE"; then
    echo "✅ SEUIL AUDIO TROUVÉ"
    grep -B 1 -A 1 "audioLevel >" "$FILE"
else
    echo "❌ SEUIL AUDIO ABSENT"
fi

echo ""
echo "=== 🔍 STRUCTURE DES FONCTIONS ==="
grep -n "fun.*processAudio" "$FILE"

echo ""
echo "=== 📊 RÉSUMÉ ==="
if grep -q "calculateAudioLevel" "$FILE" && grep -q "consecutiveVoiceDetections" "$FILE"; then
    echo "✅ TOUT EST PRÉSENT DANS LE FICHIER"
else
    echo "❌ ÉLÉMENTS MANQUANTS"
fi
