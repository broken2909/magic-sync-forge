#!/bin/bash
echo "🔍 VÉRIFICATION SON WELCOME_SOUND"

# 1. Vérifier si le fichier son existe
echo ""
echo "📋 1. FICHIER WELCOME_SOUND DANS RAW"
find app/src/main/res -name "welcome_sound.mp3" -o -name "welcome_sound.*" 2>/dev/null

# 2. Vérifier le code dans FirstLaunchWelcome
echo ""
echo "📋 2. CODE CHARGEMENT SON DANS FIRSTLAUNCHWELCOME"
grep -A 10 "loadWelcomeSound" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt

# 3. Vérifier l'appel dans MainActivity
echo ""
echo "📋 3. APPEL FIRSTLAUNCHWELCOME DANS MAINACTIVITY"
grep -B 2 -A 2 "FirstLaunchWelcome.playWelcomeIfFirstLaunch" app/src/main/java/com/magiccontrol/MainActivity.kt

# 4. Vérifier le nom de la ressource
echo ""
echo "📋 4. RESSOURCES RAW DISPONIBLES"
find app/src/main/res -name "*.mp3" -o -name "*.wav" -o -name "*.ogg" 2>/dev/null

echo ""
echo "🔍 DIAGNOSTIC TERMINÉ"
