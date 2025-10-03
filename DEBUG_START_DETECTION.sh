#!/bin/bash

echo "🔍 DEBUG startWakeWordDetection()"

echo "=== Méthode startWakeWordDetection ==="
grep -n -A20 "startWakeWordDetection" app/src/main/java/com/magiccontrol/service/WakeWordService.kt

echo ""
echo "=== Méthode startListening ==="
grep -n -A30 "fun startListening()" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt | head -40
