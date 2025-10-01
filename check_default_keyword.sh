#!/bin/bash
echo "🔍 VÉRIFICATION VALEUR PAR DÉFAUT 'magic'"

echo ""
echo "📋 Recherche valeur par défaut dans PreferencesManager..."
grep -A 5 -B 5 "getActivationKeyword" app/src/main/java/com/magiccontrol/utils/PreferencesManager.kt

echo ""
echo "📋 Vérification valeur de retour par défaut..."
if grep -q "magic" app/src/main/java/com/magiccontrol/utils/PreferencesManager.kt; then
    echo "✅ 'magic' trouvé comme valeur par défaut"
else
    echo "❌ 'magic' non trouvé - vérification nécessaire"
fi

echo ""
echo "🔍 VÉRIFICATION TERMINÉE"
