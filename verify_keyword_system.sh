#!/bin/bash
echo "🔍 VÉRIFICATION SYSTÈME DÉTECTION MOT-CLÉ"

# 1. Vérification PreferencesManager
echo ""
echo "📋 1. VÉRIFICATION PreferencesManager.kt"
if [ -f "app/src/main/java/com/magiccontrol/utils/PreferencesManager.kt" ]; then
    echo "✅ Fichier trouvé"
    grep -n "getActivationKeyword\|setActivationKeyword" app/src/main/java/com/magiccontrol/utils/PreferencesManager.kt || echo "❌ Méthodes manquantes"
else
    echo "❌ Fichier manquant"
fi

# 2. Vérification WakeWordDetector
echo ""
echo "📋 2. VÉRIFICATION WakeWordDetector.kt"
if [ -f "app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt" ]; then
    echo "✅ Fichier trouvé"
    grep -n "PreferencesManager\|getActivationKeyword" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt || echo "❌ Référence PreferencesManager manquante"
else
    echo "❌ Fichier manquant"
fi

# 3. Vérification KeywordUtils
echo ""
echo "📋 3. VÉRIFICATION KeywordUtils.kt"
if [ -f "app/src/main/java/com/magiccontrol/utils/KeywordUtils.kt" ]; then
    echo "✅ Fichier trouvé"
    grep -n "isValidKeyword\|getSupportedKeywords" app/src/main/java/com/magiccontrol/utils/KeywordUtils.kt || echo "❌ Méthodes de validation manquantes"
else
    echo "❌ Fichier manquant"
fi

# 4. Vérification valeur par défaut
echo ""
echo "📋 4. VALEUR PAR DÉFAUT 'magic'"
find app/src/main/java/com/magiccontrol/ -name "*.kt" -exec grep -l "magic" {} \; | head -5

echo ""
echo "🔍 VÉRIFICATION TERMINÉE"
