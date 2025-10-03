#!/bin/bash

echo "🚀 PUSH COMPLET VERS GITHUB"

# Initialiser le repo git
git init

# Configurer le remote
git remote add origin https://github.com/broken2909/no-see-clean.git

# Ajouter tous les fichiers
git add .

# Commit propre
git commit -m "Remplacement complet du repository - version synchronisée avec magic-sync-forge - $(date +'%Y-%m-%d %H:%M:%S')"

# Push forcé pour remplacer tout
git push -f origin main

echo "✅ PUSH TERMINÉ - Repository complètement remplacé"
