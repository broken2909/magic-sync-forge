#!/bin/bash
echo "🔍 DEBUG MESSAGE WELCOME MANQUANT"

# 1. Vérifier si WelcomeManager est appelé
echo "=== TRACE WELCOME MANAGER ==="
grep -A10 -B5 "shouldShowWelcome" app/src/main/java/com/magiccontrol/MainActivity.kt

# 2. Vérifier la logique dans handleWelcomeLogic()
echo ""
echo "=== HANDLE WELCOME LOGIC ==="
grep -A15 "handleWelcomeLogic" app/src/main/java/com/magiccontrol/MainActivity.kt

# 3. Vérifier si TTS est bien initialisé avant utilisation
echo ""
echo "=== INITIALISATION TTS ==="
grep -n "TTSManager.initialize" app/src/main/java/com/magiccontrol/MainActivity.kt

# 4. Vérifier le contenu de WelcomeManager
echo ""
echo "=== WELCOME MANAGER CONTENT ==="
grep -A20 "getWelcomeMessage" app/src/main/java/com/magiccontrol/utils/WelcomeManager.kt

# 5. Vérifier les préférences
echo ""
echo "=== POSSIBLE PROBLÈME ==="
echo "Le welcome ne se déclenche pas peut-être parce que:"
echo "   - shouldShowWelcome() retourne false (déjà montré)"
echo "   - TTS pas encore initialisé quand speak() est appelé"
echo "   - Problème de timing avec l'initialisation TTS"

echo ""
echo "🎯 SOLUTION TEST:"
echo "Forcer le welcome à s'afficher pour debug"
