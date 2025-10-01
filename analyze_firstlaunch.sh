#!/bin/bash
echo "🔍 ANALYSE DÉTAILLÉE FIRSTLAUNCHWELCOME"

# 1. Vérification syntaxe et structure
echo ""
echo "📋 1. ANALYSE SYNTAXE"
echo "Lignes de code: $(wc -l < app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt)"
echo "Caractères: $(wc -m < app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt)"

# 2. Vérification des imports
echo ""
echo "📋 2. IMPORTS"
grep "^import" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt

# 3. Vérification des méthodes
echo ""
echo "📋 3. MÉTHODES ET FERMETURES"
echo "Méthodes trouvées:"
grep -n "fun " app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt

# 4. Vérification timing et séquence
echo ""
echo "📋 4. TIMING ET SÉQUENCE"
echo "Séquence détectée dans playWelcomeIfFirstLaunch:"
grep -n "welcomeSound\|TTSManager.speak\|prefs.edit" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt

# 5. Vérification messages
echo ""
echo "📋 5. MESSAGES"
echo "Message FR:"
grep -A 1 'val unifiedMessage = if (currentLanguage == "fr")' app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt | tail -1
echo "Message EN:"
grep -A 1 '} else {' app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt | tail -1

# 6. Vérification fermetures
echo ""
echo "📋 6. FERMETURES"
echo "Accolades ouvrantes: $(grep -o "{" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt | wc -l)"
echo "Accolades fermantes: $(grep -o "}" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt | wc -l)"

# 7. Vérification erreurs potentielles
echo ""
echo "📋 7. ERREURS POTENTIELLES"
if ! grep -q "PreferencesManager" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt; then
    echo "❌ PreferencesManager non importé"
else
    echo "✅ PreferencesManager importé"
fi

if ! grep -q "android.media.MediaPlayer" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt; then
    echo "❌ MediaPlayer non importé"
else
    echo "✅ MediaPlayer importé"
fi

echo ""
echo "🔍 ANALYSE TERMINÉE"
