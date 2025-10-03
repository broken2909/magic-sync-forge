#!/bin/bash

echo "🔧 CORRECTION SERVICE MICRO NON DÉCLENCHÉ"

# Vérifier si WakeWordService est bien déclaré et démarre
echo "🔍 Vérification WakeWordService dans AndroidManifest :"
grep -A5 -B5 "WakeWordService" app/src/main/AndroidManifest.xml

echo ""
echo "🔍 Vérification démarrage service dans MainActivity :"
grep -n "WakeWordService" app/src/main/java/com/magiccontrol/MainActivity.kt

echo ""
echo "🔍 Vérification logs de démarrage dans WakeWordService :"
grep -n "startListening\|startRecording\|Démarrage\|démarré" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | head -10
