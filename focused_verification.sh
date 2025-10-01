#!/bin/bash
echo "🎯 VÉRIFICATION CONCENTRÉE - POINTS CRITIQUES SEULEMENT"

echo ""
echo "1. 📋 DÉLAI TTS :"
grep -n "postDelayed" app/src/main/java/com/magiccontrol/tts/TTSManager.kt

echo ""
echo "2. 📋 TRADUCTION WELCOME :"
grep -n "getString.*welcome_message" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt

echo ""
echo "3. 📋 RESSOURCE WELCOME_MESSAGE :"
grep -n "welcome_message" app/src/main/res/values/strings.xml

echo ""
echo "4. 📋 ÉQUILIBRE TTSManager :"
open_braces=$(grep "{" app/src/main/java/com/magiccontrol/tts/TTSManager.kt | wc -l)
close_braces=$(grep "}" app/src/main/java/com/magiccontrol/tts/TTSManager.kt | wc -l)
echo "   Accolades: {=$open_braces }=$close_braces → $([ $open_braces -eq $close_braces ] && echo "✅ ÉQUILIBRE" || echo "❌ DÉSÉQUILIBRE")"

echo ""
echo "🎯 RÉSUMÉ VÉRIFICATION :"
echo "• Délai TTS: $(grep -q "postDelayed" app/src/main/java/com/magiccontrol/tts/TTSManager.kt && echo "✅ PRÉSENT" || echo "❌ ABSENT")"
echo "• Traduction: $(grep -q "getString.*welcome_message" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt && echo "✅ ACTIVÉE" || echo "❌ DÉSACTIVÉE")"
echo "• Ressource: $(grep -q "welcome_message" app/src/main/res/values/strings.xml && echo "✅ PRÉSENTE" || echo "❌ ABSENTE")"
echo "• Syntaxe: $([ $open_braces -eq $close_braces ] && echo "✅ CORRECTE" || echo "❌ ERRONÉE")"
