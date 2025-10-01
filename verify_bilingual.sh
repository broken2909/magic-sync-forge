#!/bin/bash
echo "🔍 VÉRIFICATION MESSAGE BILINGUE FR-EN"

# Vérifier que le message guidance a bien les deux langues
echo ""
echo "📋 CONTENU MESSAGE GUIDANCE DANS MAINACTIVITY"
grep -A 15 "MESSAGE GUIDANCE COMPLÈTEMENT ISOLÉ" app/src/main/java/com/magiccontrol/MainActivity.kt

# Vérifier la logique de détection de langue
echo ""
echo "📋 LOGIQUE DÉTECTION LANGUE"
grep -B 5 -A 10 "currentLanguage == \"fr\"" app/src/main/java/com/magiccontrol/MainActivity.kt

# Vérifier que PreferencesManager.getCurrentLanguage est importé
echo ""
echo "📋 IMPORT PREFERENCESMANAGER"
grep "import.*PreferencesManager" app/src/main/java/com/magiccontrol/MainActivity.kt

echo ""
echo "🔍 RÉSUMÉ TRADUCTION :"
if grep -q "MagicControl nécessite une activation manuelle" app/src/main/java/com/magiccontrol/MainActivity.kt && \
   grep -q "MagicControl requires manual activation" app/src/main/java/com/magiccontrol/MainActivity.kt; then
    echo "✅ MESSAGE BILINGUE FR-EN PRÉSENT"
    echo "🇫🇷 Français : Activé"
    echo "🇬🇧 English : Activated"
else
    echo "❌ PROBLEME TRADUCTION DÉTECTÉ"
fi
