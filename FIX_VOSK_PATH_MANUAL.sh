#!/bin/bash

echo "🔧 CORRECTION MANUELLE DU CHEMIN VOSK"

FILE="app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt"

# Afficher la ligne problématique
echo "📝 Ligne actuelle (119) :"
sed -n '119p' "$FILE"

# Correction précise
sed -i '119s|File(context.filesDir, "models/$currentLanguage-small")|File(context.filesDir, "models/vosk-model-small-$currentLanguage-0.22")|' "$FILE"

echo "✅ Correction appliquée"
echo "📝 Ligne corrigée (119) :"
sed -n '119p' "$FILE"
