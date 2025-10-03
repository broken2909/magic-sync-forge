#!/bin/bash
echo "🔍 DEBUG TTS - Pourquoi le message ne joue pas"

cd /data/data/com.termux/files/home/magic-sync-forge/

echo "=== 📋 WAKE WORDSERVICE - APPEL TTS ==="
grep -A 5 -B 5 "activation_prompt" app/src/main/java/com/magiccontrol/service/WakeWordService.kt

echo ""
echo "=== 📋 TTSMANAGER - CONFIGURATION ==="
grep -A 10 -B 5 "fun speak" app/src/main/java/com/magiccontrol/tts/TTSManager.kt

echo ""
echo "=== 📋 PREFERENCES - VOICE FEEDBACK ==="
grep -A 5 -B 5 "isVoiceFeedbackEnabled" app/src/main/java/com/magiccontrol/utils/PreferencesManager.kt

echo ""
echo "=== 🎯 DIAGNOSTIC RAPIDE ==="
echo "1. WakeWordService appelle-t-il TTSManager.speak()?"
echo "2. TTSManager.speak() vérifie-t-il isVoiceFeedbackEnabled?"
echo "3. Voice feedback est-il activé par défaut?"
echo "4. Y a-t-il un délai ou blocage?"
