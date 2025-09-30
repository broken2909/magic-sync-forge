#!/bin/bash
echo "🗑️ SUPPRESSION DES FICHIERS .BACKUP DANS res/..."

# Recherche et suppression de tous les fichiers .backup
echo "📊 Fichiers .backup trouvés:"
find app/src/main/res -name "*.backup" -type f

# Suppression
find app/src/main/res -name "*.backup" -type f -delete

# Vérification
echo ""
echo "✅ Vérification après suppression:"
find app/src/main/res -name "*.backup" -type f

echo ""
echo "📊 État des fichiers res/:"
find app/src/main/res -name "*.xml" -type f | head -10

echo "🎯 Fichiers .backup supprimés"
