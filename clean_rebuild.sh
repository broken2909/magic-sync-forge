#!/bin/bash
echo "🧹 NETTOYAGE COMPLET DU BUILD..."

# Nettoyage des caches Gradle et rebuild
./gradlew clean

echo "✅ Nettoyage terminé"
echo "🚀 Nouveau push pour forcer la régénération du binding..."

# Nouveau commit et push
git add .
git commit -m "FIX: Nettoyage build après suppression status_text

- Clean Gradle pour régénération fichiers binding
- Suppression référence status_text du layout
- Forcer regénération ActivityMainBinding"

git push origin main

echo "📤 Push effectué"
echo "🔗 Build en cours: https://github.com/broken2909/magic-sync-forge/actions"
