#!/bin/bash
echo "🔍 VÉRIFICATION COHÉRENCE LANGUE FRANÇAIS"

# 1. Vérifier présence model Vosk français
echo ""
echo "📋 1. MODELS VOSK DANS ASSETS"
find app/src/main/assets/models/ -type d -name "*fr*" 2>/dev/null

# 2. Vérifier configuration models disponibles
echo ""
echo "📋 2. CONFIGURATION MODELS DISPONIBLES"
if [ -f "app/src/main/assets/models/models_config.json" ]; then
    echo "✅ Fichier config models trouvé"
    grep -A 10 "fr-small" app/src/main/assets/models/models_config.json || echo "❌ Model fr-small non configuré"
else
    echo "❌ Fichier config models manquant"
fi

# 3. Vérifier que ModelManager peut charger le model fr
echo ""
echo "📋 3. TEST MODEL MANAGER FRANÇAIS"
if [ -f "app/src/main/java/com/magiccontrol/utils/ModelManager.kt" ]; then
    echo "✅ ModelManager présent"
    grep -A 5 "getModelPathForLanguage.*fr" app/src/main/java/com/magiccontrol/utils/ModelManager.kt || echo "⚠️  Vérifier mapping langue fr"
else
    echo "❌ ModelManager manquant"
fi

# 4. Vérifier valeur par défaut langue
echo ""
echo "📋 4. LANGUE PAR DÉFAUT"
grep "current_language.*fr" app/src/main/java/com/magiccontrol/utils/PreferencesManager.kt

echo ""
echo "🔍 VÉRIFICATION TERMINÉE"
