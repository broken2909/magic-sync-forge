#!/bin/bash
echo "🔧 CORRECTION - VRAIE OPTION 2 (RESSOURCES SYSTÈME)"

# 1. Vérifier si R.string.welcome_message existe
echo "📋 ÉTAT ACTUEL R.string.welcome_message :"
grep -n "welcome_message" app/src/main/res/values/strings.xml

# 2. Si absent, l'ajouter
if ! grep -q "welcome_message" app/src/main/res/values/strings.xml; then
    echo "➕ AJOUT DE welcome_message dans strings.xml..."
    cat >> app/src/main/res/values/strings.xml << 'STRINGS'

    <!-- Welcome messages -->
    <string name="welcome_message">Welcome to your MagicControl voice assistant</string>
STRINGS
fi

# 3. Vérifier le code FirstLaunchWelcome
echo ""
echo "🔍 CODE FirstLaunchWelcome :"
grep -A 2 -B 2 "getString" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt

echo ""
echo "✅ VÉRIFICATION TERMINÉE :"
echo "• R.string.welcome_message doit être présent dans strings.xml"
echo "• FirstLaunchWelcome doit utiliser context.getString(R.string.welcome_message)"
echo "• Android gère AUTOMATIQUEMENT la traduction selon la langue système"
