#!/bin/bash
echo "🔍 DÉBUGAGE LANGUE TTS"

echo ""
echo "📋 CONFIGURATION TTSManager :"
grep -A 15 "setupTTSWithSystemLanguage" app/src/main/java/com/magiccontrol/tts/TTSManager.kt

echo ""
echo "🌍 TRADUCTIONS DISPONIBLES :"
find app/src/main/res -name "strings.xml" | head -5

echo ""
echo "🔧 PREMIER LANCEMENT CONFIG :"
grep -A 5 -B 5 "isFirstLaunch\\|setFirstLaunchComplete" app/src/main/java/com/magiccontrol/utils/PreferencesManager.kt

echo ""
echo "💡 DIAGNOSTIC :"
echo "Le TTS utilise la voix synthétisée car :"
echo "1. Soit la langue système n'est pas correctement détectée"
echo "2. Soit le TTS Android n'a pas la voix naturelle pour la langue"
echo "3. Soit FirstLaunchWelcome ne s'exécute pas correctement"
