#!/bin/bash

echo "🔍 VÉRIFICATION BACKUP"

BACKUP_DIR="/data/data/com.termux/files/home/backups/magic-sync-forge_backup_20251002_151504"

echo "=== 📁 CONTENU DU BACKUP ==="
find "$BACKUP_DIR" -name "WakeWordDetector.kt" -type f

echo ""
echo "=== 🔍 FICHIER WAKE WORD DETECTOR ==="
if [ -f "$BACKUP_DIR/app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt" ]; then
    echo "✅ FICHIER TROUVÉ"
    head -30 "$BACKUP_DIR/app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt"
else
    echo "❌ FICHIER NON TROUVÉ"
    find "$BACKUP_DIR" -name "*.kt" -type f | head -10
fi

echo ""
echo "=== 📊 STRUCTURE COMPLÈTE ==="
find "$BACKUP_DIR/app/src/main/java/com/magiccontrol" -name "*.kt" -type f | sort
