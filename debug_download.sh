#!/bin/bash
echo "🔍 DÉBUGAGE TÉLÉCHARGEMENT"

# Vérifier si le fichier existe et sa taille
echo ""
echo "📋 ÉTAT FICHIER MAINACTIVITY"
if [ -f "app/src/main/java/com/magiccontrol/MainActivity.kt" ]; then
    echo "✅ Fichier existe"
    echo "📏 Taille: $(wc -l < app/src/main/java/com/magiccontrol/MainActivity.kt) lignes"
    echo "📝 Contenu (premières 10 lignes):"
    head -10 app/src/main/java/com/magiccontrol/MainActivity.kt
else
    echo "❌ Fichier n'existe pas"
fi

# Vérifier l'URL GitHub
echo ""
echo "📋 VÉRIFICATION URL GITHUB"
URL="https://raw.githubusercontent.com/broken2909/magic-sync-forge/68c376b/app/src/main/java/com/magiccontrol/MainActivity.kt"
echo "🔗 URL test: $URL"
wget --spider "$URL" 2>&1 | head -2

# Tester le téléchargement manuellement
echo ""
echo "📋 TÉLÉCHARGEMENT MANUEL"
wget -O test_mainactivity.kt "$URL" 2>&1 | tail -2
if [ -f "test_mainactivity.kt" ]; then
    echo "✅ Téléchargement réussi"
    echo "📏 Taille: $(wc -l < test_mainactivity.kt) lignes"
else
    echo "❌ Échec téléchargement"
fi
