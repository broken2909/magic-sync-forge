#!/bin/bash
echo "🚨 CORRECTION D'URGENCE - SUPPRESSION TEXTE CRASHANT"

# Supprimer la ligne problématique
sed -i '/Dites Magic pour commencer/d' app/src/main/res/values/strings.xml

# Ajouter le bon message welcome_message
cat >> app/src/main/res/values/strings.xml << 'STRINGS'

    <!-- Welcome messages -->
    <string name="welcome_message">Welcome to your MagicControl voice assistant</string>
STRINGS

echo ""
echo "✅ CORRECTION APPLIQUÉE :"
echo "• ❌ 'Dites Magic pour commencer' SUPPRIMÉ"
echo "• ✅ Nouveau welcome_message AJOUTÉ"
echo "• 🔍 Vérification :"
grep -n "welcome_message" app/src/main/res/values/strings.xml
