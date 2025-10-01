#!/bin/bash
echo "🔍 ANALYSE TIMING TTS EXISTANT"

# 1. Identifier tous les appels TTSManager.speak
echo ""
echo "📋 1. APPELS TTSManager.speak DANS TOUT LE PROJET"
find app/src/main/java -name "*.kt" -exec grep -l "TTSManager.speak" {} \; | while read file; do
    echo "📍 Fichier: $file"
    grep -n "TTSManager.speak" "$file" | while read line; do
        echo "   → Ligne $line"
    done
done

# 2. Vérifier initialisation TTSManager
echo ""
echo "📋 2. INITIALISATION TTSManager"
find app/src/main/java -name "*.kt" -exec grep -l "TTSManager.initialize" {} \; | while read file; do
    echo "📍 Fichier: $file"
    grep -n "TTSManager.initialize" "$file"
done

# 3. Analyser MainActivity pour comprendre le flux
echo ""
echo "📋 3. FLUX MAINACTIVITY - MESSAGES ET TIMING"
if [ -f "app/src/main/java/com/magiccontrol/MainActivity.kt" ]; then
    echo "📍 MainActivity.kt - Structure:"
    grep -n "onCreate\|setupToolbar\|setupButtons\|startWakeWordService\|TTSManager" app/src/main/java/com/magiccontrol/MainActivity.kt
    
    echo ""
    echo "📋 Séquence détectée dans onCreate():"
    grep -A 10 "onCreate" app/src/main/java/com/magiccontrol/MainActivity.kt | grep -E "(setupToolbar|setupButtons|startWakeWordService)" || echo "❌ Séquence non claire"
fi

# 4. Vérifier WakeWordService pour messages TTS
echo ""
echo "📋 4. MESSAGES TTS DANS WAKE WORDSERVICE"
if [ -f "app/src/main/java/com/magiccontrol/service/WakeWordService.kt" ]; then
    echo "📍 WakeWordService.kt - Messages TTS:"
    grep -n "TTSManager.speak" app/src/main/java/com/magiccontrol/service/WakeWordService.kt
fi

# 5. Vérifier FirstLaunchWelcome
echo ""
echo "📋 5. FIRSTLAUNCHWELCOME"
if [ -f "app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt" ]; then
    echo "📍 FirstLaunchWelcome.kt - Contenu:"
    grep -n "speak\|TTS" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt
else
    echo "❌ FirstLaunchWelcome.kt non trouvé"
fi

echo ""
echo "🔍 ANALYSE TERMINÉE - RÉSUMÉ DES RISQUES TIMING"
