#!/bin/bash
echo "🔍 VÉRIFICATION LIAISON AUDIO-MICRO"

cd /data/data/com.termux/files/home/magic-sync-forge/

echo "=== 📊 WAKE WORD DETECTOR - MESURE AUDIO ==="
grep -A 10 -B 5 "calculateAudioLevel\|audioLevel\|bytesRead" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

echo ""
echo "=== 🎯 POINTS DE VÉRIFICATION ==="
echo "1. Le code lit-il les bytes audio? (bytesRead > 0)"
echo "2. Calcule-t-il le niveau audio? (calculateAudioLevel)"
echo "3. Loggue-t-il le niveau audio détecté?"
echo "4. Y a-t-il une liaison entre parole et détection?"

echo ""
echo "=== 🔧 DIAGNOSTIC RAPIDE ==="
if grep -q "calculateAudioLevel" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt; then
    echo "✅ Mesure niveau audio présente"
else
    echo "❌ AUCUNE mesure audio - Micro peut être muet"
fi

if grep -q "bytesRead.*0" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt; then
    echo "✅ Vérification bytes audio présente" 
else
    echo "❌ Pas de vérification bytes audio"
fi
