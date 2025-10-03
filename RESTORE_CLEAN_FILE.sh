#!/bin/bash

echo "🛠️ RESTAURATION FICHIER PROPRE"

PROJECT_DIR="/data/data/com.termux/files/home/magic-sync-forge"
cd "$PROJECT_DIR"

# Restaurer depuis la sauvegarde originale
if [ -f "app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt.backup2" ]; then
    cp "app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt.backup2" "app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt"
    echo "✅ Fichier restauré depuis backup2"
else
    echo "❌ Aucune sauvegarde propre trouvée"
    exit 1
fi

echo ""
echo "🔍 CONTENU RESTAURÉ :"
head -50 app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

echo ""
echo "🎯 PROCHAINES ÉTAPES :"
echo "1. Vérifier que le fichier est propre"
echo "2. Ajouter UNIQUEMENT startRecording() au bon endroit"
echo "3. Tester étape par étape"
