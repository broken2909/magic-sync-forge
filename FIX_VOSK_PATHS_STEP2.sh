#!/bin/bash

echo "🔧 CORRECTION CHEMINS VOSK - ÉTAPE 2/2"

# Sauvegarde
cp app/src/main/java/com/magiccontrol/utils/ModelManager.kt app/src/main/java/com/magiccontrol/utils/ModelManager.kt.backup_step2

# Correction des chemins dans ModelManager
sed -i 's|"models/vosk-model-small-fr"|"models/vosk-model-small-fr-0.22"|g' app/src/main/java/com/magiccontrol/utils/ModelManager.kt
sed -i 's|"models/vosk-model-small-en-us"|"models/vosk-model-small-en-us-0.22"|g' app/src/main/java/com/magiccontrol/utils/ModelManager.kt

echo "✅ Étape 2 terminée - ModelManager corrigé"
echo "🔍 Vérification :"
grep -n "models/vosk-model-small" app/src/main/java/com/magiccontrol/utils/ModelManager.kt
