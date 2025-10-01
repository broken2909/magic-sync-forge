#!/bin/bash
echo "🔍 VÉRIFICATION MODELMANAGER.GETMODELPATHFORLANGUAGE"

# 1. Afficher la méthode getModelPathForLanguage
echo ""
echo "📋 1. MÉTHODE GETMODELPATHFORLANGUAGE"
if [ -f "app/src/main/java/com/magiccontrol/utils/ModelManager.kt" ]; then
    grep -A 10 "fun getModelPathForLanguage" app/src/main/java/com/magiccontrol/utils/ModelManager.kt
else
    echo "❌ ModelManager.kt non trouvé"
fi

# 2. Vérifier la structure réelle des dossiers models
echo ""
echo "📋 2. STRUCTURE RÉELLE DES MODELS DANS ASSETS"
find app/src/main/assets/models/ -type d -name "vosk-model-small-*" 2>/dev/null

# 3. Vérifier l'appel dans WakeWordDetector
echo ""
echo "📋 3. APPEL DANS WAKE WORD DETECTOR"
grep -B 5 -A 5 "ModelManager.getModelPathForLanguage" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

# 4. Vérifier le constructeur Model dans WakeWordDetector
echo ""
echo "📋 4. CONSTRUCTEUR MODEL PROBLEMATIQUE"
grep -n "Model(context.assets" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

echo ""
echo "🔍 ANALYSE TERMINÉE"
