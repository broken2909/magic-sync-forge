#!/bin/bash
echo "🚀 PRÉPARATION DU PUSH GIT..."

# Vérification de l'état Git
echo "📊 État des modifications:"
git status --short

# Ajout des fichiers modifiés
git add app/src/main/res/layout/activity_main.xml

# Commit des corrections
git commit -m "FIX: Correction XML layout - suppression référence welcome_message manquante

- Suppression du TextView référençant welcome_message manquant
- Layout XML maintenant valide pour la compilation
- Interface épurée conservée sans message texte"

# Push vers GitHub
echo "📤 Push vers GitHub..."
git push origin main

echo "✅ Push terminé - Vérification du build GitHub..."
echo "🔗 https://github.com/broken2909/magic-sync-forge/actions"
