#!/bin/bash
echo "🔍 VÉRIFICATION ORDRE RÉEL D'EXÉCUTION"

# 1. Vérifier MainActivity - séquence réelle
echo ""
echo "📋 1. MAINACTIVITY - ORDRE RÉEL"
grep -n "onCreate\|FirstLaunchWelcome\|startWakeWordService\|setupButtons" app/src/main/java/com/magiccontrol/MainActivity.kt

# 2. Vérifier FirstLaunchWelcome - quand est-il appelé ?
echo ""
echo "📋 2. FIRSTLAUNCHWELCOME - APPEL ?"
find app/src/main/java -name "*.kt" -exec grep -l "FirstLaunchWelcome" {} \; | while read file; do
    echo "📍 Appel dans: $file"
    grep -n "FirstLaunchWelcome" "$file"
done

# 3. Vérifier permissions micro
echo ""
echo "📋 3. PERMISSIONS MICRO - QUAND ?"
find app/src/main/java -name "*.kt" -exec grep -l "RECORD_AUDIO\|permission" {} \; | while read file; do
    echo "📍 Fichier: $file"
    grep -n "RECORD_AUDIO\|requestPermissions\|Permission" "$file" | head -3
done

# 4. Vérifier WakeWordService - messages TTS
echo ""
echo "📋 4. WAKEWORDSERVICE - MESSAGES"
grep -n "TTSManager.speak\|onStartCommand" app/src/main/java/com/magiccontrol/service/WakeWordService.kt

echo ""
echo "🔍 VÉRIFICATION TERMINÉE - ORDRE RÉEL À IDENTIFIER"
