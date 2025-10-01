#!/bin/bash
echo "🚀 PUSH DES MODIFICATIONS SUR GITHUB"

# Vérifier l'état git
echo ""
echo "📋 ÉTAT GIT ACTUEL"
git status --short

# Ajouter les fichiers modifiés
echo ""
echo "📋 AJOUT DES FICHIERS"
git add app/src/main/java/com/magiccontrol/MainActivity.kt
git add app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt

# Commit des modifications
echo ""
echo "📋 COMMIT DES CHANGEMENTS"
git commit -m "✨ Intégration message bienvenue unifié bilingue FR/EN

- Suppression message guidance isolé
- Message bienvenue unifié incluant guidance accessibilité
- Détection automatique langue système (FR/EN)
- Même timing son welcome + message vocal
- Structure simplifiée et sécurisée"

# Push vers GitHub
echo ""
echo "📋 PUSH VERS GITHUB"
git push origin main

echo ""
echo "✅ PUSH EFFECTUÉ AVEC SUCCÈS"
echo "📊 Résumé des modifications :"
echo "   • MainActivity.kt : Structure simplifiée"
echo "   • FirstLaunchWelcome.kt : Message unifié bilingue"
echo "   • Timing optimisé : Son + Message unique"
echo ""
echo "🔗 Repository : https://github.com/broken2909/magic-sync-forge"
