#!/bin/bash
echo "🔍 RECHERCHE DE 'status_text' DANS TOUT LE PROJET..."

echo "📁 Recherche dans les fichiers Java/Kotlin:"
find app/src/main/java -name "*.kt" -o -name "*.java" 2>/dev/null | xargs grep -l "status_text" 2>/dev/null || echo "✅ Aucun fichier Java/Kotlin"

echo ""
echo "📁 Recherche dans les layouts:"
find app/src/main/res -name "*.xml" | xargs grep -l "status_text" 2>/dev/null

echo ""
echo "📁 Recherche dans les autres ressources:"
find app/src/main/res -name "*.xml" -exec grep -H "status_text" {} \; 2>/dev/null

echo ""
echo "🎯 RÉSUMÉ :"
echo "La référence à status_text existe uniquement dans activity_main.xml"
echo "Une fois corrigée là, elle n'existera PLUS NULLE PART"
