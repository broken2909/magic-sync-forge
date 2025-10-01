#!/bin/bash
echo "📦 ÉTAPE 1: BACKUP SÉPARÉ"

BACKUP_DIR="backup_vosk_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup uniquement du fichier problématique
cp app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt "$BACKUP_DIR/WakeWordDetector.backup.kt"

echo "✅ BACKUP TERMINÉ"
echo "📁 Dossier: $BACKUP_DIR/"
echo "📄 Fichier: WakeWordDetector.backup.kt"
echo ""
echo "🔍 Contenu backup:"
ls -la "$BACKUP_DIR/"
