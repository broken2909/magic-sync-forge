#!/bin/bash

echo "🔍 VÉRIFICATION LOGIQUE EXTRACTION VOSK"

echo "=== Condition wasExtractionNeeded ==="
grep -n -A5 -B5 "wasExtractionNeeded" app/src/main/java/com/magiccontrol/service/ModelDownloadService.kt

echo ""
echo "=== Logs extraction ==="
grep -n "extraction necessaire\|modeles deja presents" app/src/main/java/com/magiccontrol/service/ModelDownloadService.kt

echo ""
echo "=== Démarrage ModelDownloadService ==="
grep -n "ModelDownloadService" app/src/main/java/com/magiccontrol/MainActivity.kt
