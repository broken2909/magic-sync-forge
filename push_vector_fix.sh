#!/bin/bash
echo "🚀 PUSH DE LA CORRECTION DU VECTOR DRAWABLE..."

# Vérification des modifications
echo "📊 Modifications à pousser:"
git status --short

# Ajout du fichier corrigé
git add app/src/main/res/drawable/ic_magic_control.xml

# Commit avec description claire
git commit -m "FIX: Correction VectorDrawable ic_magic_control.xml

- Suppression du préfixe android: des attributs vector drawable
- Attributs corrigés: android:cx → cx, android:cy → cy, android:r → r
- android:fill → fill, android:stroke → stroke
- Conformité aux standards Android VectorDrawable
- Le logo visuel reste identique"

# Push vers GitHub
echo "📤 Push vers GitHub..."
git push origin main

echo "✅ Push terminé"
echo "🔗 Vérification du build: https://github.com/broken2909/magic-sync-forge/actions"
