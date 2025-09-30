#!/bin/bash
echo "🔍 RECHERCHE DU LOGO MAGICCONTROL..."

echo "📁 Fichiers drawable existants:"
find app/src/main/res/drawable -name "*.xml" -o -name "*.png" 2>/dev/null

echo ""
echo "🎯 Référence dans le layout:"
grep -n "ic_magic_control" app/src/main/res/layout/activity_main.xml

echo ""
echo "📊 Vérification existence ic_magic_control:"
if [ -f "app/src/main/res/drawable/ic_magic_control.xml" ]; then
    echo "✅ Fichier ic_magic_control.xml existe"
    echo "📝 Contenu:"
    head -20 app/src/main/res/drawable/ic_magic_control.xml
else
    echo "❌ Fichier ic_magic_control.xml N'EXISTE PAS"
fi

echo ""
echo "🔍 Recherche d'autres logos possibles:"
find app/src/main/res -name "*magic*" -o -name "*control*" -o -name "*logo*" 2>/dev/null
