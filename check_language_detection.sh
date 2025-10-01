#!/bin/bash
echo "🔍 VÉRIFICATION DÉTECTION LANGUE SYSTÈME"

echo ""
echo "📋 FONCTION setupTTSWithSystemLanguage :"
grep -A 25 "private fun setupTTSWithSystemLanguage" app/src/main/java/com/magiccontrol/tts/TTSManager.kt

echo ""
echo "📋 TRADUCTIONS DISPONIBLES :"
find app/src/main/res -name "strings.xml" | head -3

echo ""
echo "💡 PROBLÈME POTENTIEL :"
echo "Même avec setupTTSWithSystemLanguage(), le TTS Android peut :"
echo "1. Ne pas avoir la voix naturelle pour la langue système"
echo "2. Utiliser une voix synthétisée par défaut"
echo "3. Avoir un délai de chargement des voix naturelles"

echo ""
echo "🎯 TEST DÉCISIF :"
echo "• Si le message JOUE mais en voix synthétisée → problème TTS device"
echo "• Si le message NE JOUE PAS → problème initialisation/délai"
echo "• Si le message joue en MAUVAISE LANGUE → problème détection"
