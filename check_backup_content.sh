#!/bin/bash
echo "🔍 VÉRIFICATION CONTENU DES BACKUPS"

# Trouver les dossiers de backup les plus récents
VOSK_BACKUP=$(find . -name "backup_vosk_*" -type d | head -1)
RESTORE_BACKUP=$(find . -name "backup_before_restore_*" -type d | head -1)

echo ""
echo "📋 BACKUP VOSK: $VOSK_BACKUP"
if [ -n "$VOSK_BACKUP" ]; then
    echo "📍 WakeWordDetector.backup.kt - Message guidance:"
    grep -c "activation manuelle" "$VOSK_BACKUP/WakeWordDetector.backup.kt" | xargs echo "   • Présence message guidance:"
    grep -c "Model(context.assets" "$VOSK_BACKUP/WakeWordDetector.backup.kt" | xargs echo "   • Constructeur Vosk problématique:"
else
    echo "❌ Backup Vosk non trouvé"
fi

echo ""
echo "📋 BACKUP RESTAURATION: $RESTORE_BACKUP"
if [ -n "$RESTORE_BACKUP" ]; then
    echo "📍 MainActivity.current.kt - Message guidance:"
    grep -c "activation manuelle" "$RESTORE_BACKUP/MainActivity.current.kt" | xargs echo "   • Présence message guidance:"
    grep -c "FirstLaunchWelcome" "$RESTORE_BACKUP/MainActivity.current.kt" | xargs echo "   • Appel FirstLaunchWelcome:"
    
    echo ""
    echo "📍 FirstLaunchWelcome.current.kt - Message guidance:"
    grep -c "activation manuelle" "$RESTORE_BACKUP/FirstLaunchWelcome.current.kt" | xargs echo "   • Présence message guidance:"
    grep -c "Bienvenue dans" "$RESTORE_BACKUP/FirstLaunchWelcome.current.kt" | xargs echo "   • Message bienvenue simple:"
    
    echo ""
    echo "📍 WakeWordDetector.current.kt - Constructeur:"
    grep -c "Model(inputStream" "$RESTORE_BACKUP/WakeWordDetector.current.kt" | xargs echo "   • Constructeur InputStream:"
    grep -c "Model(modelDir.absolutePath" "$RESTORE_BACKUP/WakeWordDetector.current.kt" | xargs echo "   • Constructeur chemin fichier:"
else
    echo "❌ Backup restauration non trouvé"
fi

echo ""
echo "🎯 ANALYSE:"
echo "Nous cherchons la version AVANT message guidance (état stable)"
