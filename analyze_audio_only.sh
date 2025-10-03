#!/bin/bash
echo "🔍 ANALYSE PRÉCISE - QUE AJOUTER ?"

cd /data/data/com.termux/files/home/magic-sync-forge/

echo "=== 📋 CODE ACTUEL - POINT D'INSERTION ==="
grep -n -A 5 "bytesRead > 0" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

echo ""
echo "=== 🎯 CE QUI MANQUE EXACTEMENT ==="
echo "APRES: 'if (bytesRead > 0) {'"
echo "IL FAUT AJOUTER:"
echo "1. Mesure niveau audio"
echo "2. Détection présence voix" 
echo "3. Log du niveau audio"
echo ""
echo "SANS TOUCHER:"
echo "- detectionTimer"
echo "- onWakeWordDetected"
echo "- Structure existante"
