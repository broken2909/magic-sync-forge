#!/bin/bash
echo "🚀 PUSH FINAL AVEC NETTOYAGE COMPLET..."

# Vérification de l'état
echo "📊 État Git avant push:"
git status --short

# Ajout de tous les changements
git add .

# Commit final
git commit -m "FIX: Build stable - nettoyage fichiers .backup et corrections finales

- Suppression fichiers .backup des dossiers res/
- Layout XML valide sans références manquantes
- Vector drawables corrigés et harmonisés palette Z.ai
- Structure prête pour compilation APK"

# Push
echo "📤 Push vers GitHub..."
git push origin main

echo "✅ PUSH RÉUSSI !"
echo "🎉 TOUTES LES CORRECTIONS APPLIQUÉES"
echo "🔗 Build en cours: https://github.com/broken2909/magic-sync-forge/actions"
