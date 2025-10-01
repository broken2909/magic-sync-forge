#!/bin/bash
echo "🔍 VÉRIFICATION ACTIVATION SERVICES SYSTÈME"

# 1. Vérifier activation WakeWordService dans MainActivity
echo ""
echo "📋 1. ACTIVATION WAKE WORD SERVICE"
if grep -q "WakeWordService" app/src/main/java/com/magiccontrol/MainActivity.kt; then
    echo "✅ WakeWordService référencé dans MainActivity"
    grep -n "WakeWordService" app/src/main/java/com/magiccontrol/MainActivity.kt
else
    echo "❌ WakeWordService NON activé dans MainActivity"
fi

# 2. Vérifier callback vers FullRecognitionService
echo ""
echo "📋 2. CALLBACK WAKE WORD → FULL RECOGNITION"
if grep -q "FullRecognitionService" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
    echo "✅ Callback présent"
    grep -n "FullRecognitionService" app/src/main/java/com/magiccontrol/service/WakeWordService.kt
else
    echo "❌ Callback MANQUANT - La détection ne lance pas la reconnaissance"
fi

# 3. Vérifier message guidance TTS
echo ""
echo "📋 3. MESSAGE GUIDANCE TTS"
if grep -q "TTSManager.speak" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
    echo "✅ TTS utilisé dans WakeWordService"
    grep -n "TTSManager.speak" app/src/main/java/com/magiccontrol/service/WakeWordService.kt
else
    echo "❌ AUCUN message guidance TTS"
fi

# 4. Vérifier valeur défaut langue
echo ""
echo "📋 4. VALEUR DÉFAUT LANGUE"
grep -A 2 -B 2 "getCurrentLanguage" app/src/main/java/com/magiccontrol/utils/PreferencesManager.kt

echo ""
echo "🔍 VÉRIFICATION TERMINÉE"
