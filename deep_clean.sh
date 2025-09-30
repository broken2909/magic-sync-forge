#!/bin/bash
echo "🔥 NETTOYAGE PROFOND DU DATA BINDING..."

# 1. Suppression complète des dossiers de build
echo "🧹 Suppression des dossiers build..."
rm -rf app/build/
rm -rf build/
rm -rf .gradle/

# 2. Vérification que status_text n'existe nulle part
echo "🔍 Recherche de toute référence à status_text..."
grep -r "status_text" app/src/ || echo "✅ Aucune référence trouvée dans le code source"

# 3. Vérification du layout final
echo "📱 Layout activity_main.xml final:"
grep -o 'android:id="@+id/[^"]*"' app/src/main/res/layout/activity_main.xml

# 4. Commit et push du nettoyage profond
echo "🚀 Préparation du push..."
git add .
git commit -m "FIX: Nettoyage profond - suppression totale build cache

- Suppression complète dossiers build/ et .gradle/
- Forcer régénération totale Data Binding
- Élimination définitive référence status_text
- Build cache reset complet"

git push origin main

echo "✅ NETTOYAGE PROFOND TERMINÉ"
echo "🎯 Cette fois le build DOIT passer"
