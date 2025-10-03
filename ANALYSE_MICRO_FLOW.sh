#!/bin/bash

echo "🔍 ANALYSE FLUX MICRO - ÉTAPE PAR ÉTAPE"

echo "=== 1. CALLBACK PERMISSION DANS MainActivity ==="
grep -n -A15 "requestPermissionLauncher" app/src/main/java/com/magiccontrol/MainActivity.kt

echo ""
echo "=== 2. DÉMARRAGE WakeWordService ==="
grep -n -A10 "startVoiceServices" app/src/main/java/com/magiccontrol/MainActivity.kt

echo ""
echo "=== 3. INITIALISATION DANS WakeWordService ==="
grep -n -A10 "onStartCommand" app/src/main/java/com/magiccontrol/service/WakeWordService.kt
