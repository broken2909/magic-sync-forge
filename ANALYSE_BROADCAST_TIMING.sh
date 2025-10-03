#!/bin/bash

echo "🔍 ANALYSE TIMING DU BROADCAST VOSK"

echo "=== Vérification quand le broadcast est envoyé ==="
find . -name "*.kt" -type f | xargs grep -l "EXTRACTION_COMPLETE" | grep -v ".backup" | while read file; do
    echo "📁 Fichier: $file"
    grep -n -A10 -B10 "EXTRACTION_COMPLETE" "$file" | head -20
    echo "---"
done

echo ""
echo "=== Vérification ordre démarrage services ==="
grep -n "startService.*ModelDownloadService\|startService.*WakeWordService" app/src/main/java/com/magiccontrol/MainActivity.kt
