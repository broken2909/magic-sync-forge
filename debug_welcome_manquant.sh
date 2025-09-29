#!/bin/bash
echo "🔍 DEBUG: POURQUOI LE WELCOME NE S'AFFICHE PAS"

# 1. Vérifier la logique shouldPlayWelcomeVoice
echo "=== LOGIQUE SHOULD PLAY WELCOME ==="
grep -A10 "shouldPlayWelcomeVoice" app/src/main/java/com/magiccontrol/welcome/AppWelcomeManager.kt

# 2. Vérifier si TTS est initialisé avant utilisation
echo ""
echo "=== SÉQUENCE D'INITIALISATION ==="
grep -n "TTSManager.initialize" app/src/main/java/com/magiccontrol/MainActivity.kt
grep -A5 "handleIndependentWelcome" app/src/main/java/com/magiccontrol/MainActivity.kt

# 3. Vérifier le message exact
echo ""
echo "=== MESSAGE WELCOME EXACT ==="
grep -n "Bienvenue dans votre assistant vocal MagicControl" app/src/main/java/com/magiccontrol/welcome/AppWelcomeManager.kt

# 4. Vérifier les préférences (peut-être déjà marqué comme vu)
echo ""
echo "=== ÉTAT DES PRÉFÉRENCES ==="
echo "La clé utilisée: welcome_shown_v1"
echo "Si cette clé existe et est true, le welcome ne se déclenchera PAS"

# 5. Problème potentiel : timing TTS
echo ""
echo "🎯 DIAGNOSTIC:"
echo "Problème probable: TTS pas encore initialisé quand speak() est appelé"
echo "Solution: Ajouter un délai ou callback après TTS.initialize()"
