#!/bin/bash
echo "🔍 VÉRIFICATION DES RÉFÉRENCES DANS MainActivity.kt..."

# Recherche des références à status_text dans le code
echo "📝 Références à status_text dans MainActivity.kt:"
grep -n "status_text" app/src/main/java/com/magiccontrol/MainActivity.kt

echo ""
echo "📊 IDs présents dans le layout activity_main.xml:"
grep -o 'android:id="@+id/[^"]*"' app/src/main/res/layout/activity_main.xml | sed 's/.*@+id\///' | sed 's/"//'

echo ""
echo "🎯 Analyse :"
echo "Le code essaye d'accéder à binding.status_text qui n'existe plus dans le layout"
