#!/bin/bash

echo "🔍 ANALYSE DÉMARRAGE SERVICE - LIGNE PAR LIGNE"

echo "=== MainActivity.kt lignes 105-110 ==="
sed -n '105,110p' app/src/main/java/com/magiccontrol/MainActivity.kt

echo ""
echo "=== WakeWordService.kt lignes 30-35 ==="
sed -n '30,35p' app/src/main/java/com/magiccontrol/service/WakeWordService.kt

echo ""
echo "=== Vérification startListening() ==="
grep -n "startListening()" app/src/main/java/com/magiccontrol/service/WakeWordService.kt
