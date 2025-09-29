#!/bin/bash
echo "🔍 DEBUG: POURQUOI TTS NE DÉTECTE PAS LA LANGUE"

# 1. Vérifier comment TTSManager configure la langue
echo "=== CONFIGURATION LANGUE TTSManager ==="
grep -A10 "setupTTS" app/src/main/java/com/magiccontrol/tts/TTSManager.kt

# 2. Vérifier PreferencesManager.getCurrentLanguage()
echo ""
echo "=== DÉTECTION LANGUE PRÉFÉRENCES ==="
grep -A5 "getCurrentLanguage" app/src/main/java/com/magiccontrol/utils/PreferencesManager.kt

# 3. Vérifier la logique de détection
echo ""
echo "=== LOGIQUE DÉTECTION LANGUE ==="
echo "TTSManager utilise: PreferencesManager.getCurrentLanguage(context)"
echo "Mais getCurrentLanguage() retourne peut-être toujours 'fr' par défaut"

# 4. Solution: Utiliser la locale système directement
echo ""
echo "🎯 SOLUTION:"
echo "Remplacer dans TTSManager:"
echo "PreferencesManager.getCurrentLanguage(context) → Locale.getDefault().language"
