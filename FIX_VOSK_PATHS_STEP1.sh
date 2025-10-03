#!/bin/bash

echo "🔧 CORRECTION CHEMINS VOSK - ÉTAPE 1/2"

# Sauvegarde
cp app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt.backup_step1

# Correction du chemin dans WakeWordDetector
sed -i 's|File(context.filesDir, "models/$finalLanguage-small")|File(context.filesDir, "models/vosk-model-small-$finalLanguage-0.22")|g' app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

echo "✅ Étape 1 terminée - WakeWordDetector corrigé"
echo "🔍 Vérification :"
grep -n "models/vosk-model-small" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt
