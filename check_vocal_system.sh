#!/bin/bash
echo "🔍 VÉRIFICATION COMPLÈTE SYSTÈME VOCAL"

# 1. Vérification structure reconnaissance vocale
echo ""
echo "📋 1. STRUCTURE RECONNAISSANCE VOCALE"
find app/src/main/java/com/magiccontrol/ -name "*.kt" | grep -E "(recognizer|tts|system)" | sort

# 2. Vérification gestion langues
echo ""
echo "📋 2. GESTION MULTI-LANGUE"
if [ -f "app/src/main/java/com/magiccontrol/utils/PreferencesManager.kt" ]; then
    echo "✅ PreferencesManager trouvé"
    grep -n "getCurrentLanguage\|setCurrentLanguage" app/src/main/java/com/magiccontrol/utils/PreferencesManager.kt || echo "❌ Gestion langue manquante"
fi

# 3. Vérification ModelManager
echo ""
echo "📋 3. GESTION MODELS VOSK"
if [ -f "app/src/main/java/com/magiccontrol/utils/ModelManager.kt" ]; then
    echo "✅ ModelManager trouvé"
    grep -n "getModelPathForLanguage\|isModelAvailable" app/src/main/java/com/magiccontrol/utils/ModelManager.kt || echo "❌ Méthodes models manquantes"
else
    echo "❌ ModelManager manquant"
fi

# 4. Vérification intégration WakeWordDetector
echo ""
echo "📋 4. INTÉGRATION LANGUE DANS WAKE WORD"
if [ -f "app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt" ]; then
    echo "✅ WakeWordDetector trouvé"
    grep -n "PreferencesManager.getCurrentLanguage\|ModelManager.getModelPathForLanguage" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt || echo "❌ Intégration langue manquante"
fi

# 5. Vérification TTS multi-langue
echo ""
echo "📋 5. TTS MULTI-LANGUE"
if [ -f "app/src/main/java/com/magiccontrol/tts/TTSManager.kt" ]; then
    echo "✅ TTSManager trouvé"
    grep -n "getCurrentLanguage\|Locale" app/src/main/java/com/magiccontrol/tts/TTSManager.kt || echo "❌ Gestion langue TTS manquante"
fi

# 6. Vérification assets models
echo ""
echo "📋 6. MODELS DANS ASSETS"
find app/src/main/assets/ -type f -name "*.json" -o -name "*.md" 2>/dev/null | head -10

echo ""
echo "🔍 VÉRIFICATION TERMINÉE"
