#!/bin/bash

echo "🔍 DEBUG DÉMARRAGE SERVICE"

PROJECT_DIR="/data/data/com.termux/files/home/magic-sync-forge"
cd "$PROJECT_DIR"

echo "=== 🔍 WAKE WORD SERVICE ==="
grep -n "startListening\|startRecording\|isListening" app/src/main/java/com/magiccontrol/service/WakeWordService.kt

echo ""
echo "=== 🔍 INITIALISATION AUDIORECORD ==="
grep -B 10 -A 10 "AudioRecord(" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

echo ""
echo "=== 🔍 GESTION D'ERREURS ==="
grep -B 5 -A 5 "try\|catch\|Exception" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt | head -20

echo ""
echo "🎯 POINTS À VÉRIFIER :"
echo "1. WakeWordService.startWakeWordDetection() appelé ?"
echo "2. AudioRecord() initialisé sans erreur ?"
echo "3. audioRecord.startRecording() réussi ?"
echo "4. La boucle while(isListening) démarre ?"
