#!/bin/bash
echo "🔍 VÉRIFICATION FINALE AVANT PUSH"

echo ""
echo "📋 RESSOURCE welcome_message :"
grep -n "welcome_message" app/src/main/res/values/strings.xml

echo ""
echo "🔧 CODE FirstLaunchWelcome :"
grep -n "getString.*welcome_message" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt

echo ""
echo "🌍 TRADUCTION FRANÇAISE :"
[ -f "app/src/main/res/values-fr/strings.xml" ] && grep "welcome_message" app/src/main/res/values-fr/strings.xml || echo "❌ Fichier français manquant"

echo ""
echo "✅ ÉTAT FINAL :"
if grep -q "welcome_message" app/src/main/res/values/strings.xml && \
   grep -q "getString.*welcome_message" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt; then
    echo "• ✅ Système de traduction PRÊT"
    echo "• ✅ Ressource welcome_message PRÉSENTE" 
    echo "• ✅ Code utilisant getString() CORRECT"
    echo "• 🚀 Prêt pour push et test langue système"
else
    echo "• ❌ Problème détecté - vérification nécessaire"
fi
