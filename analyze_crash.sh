#!/bin/bash
echo "🔍 Analyse des causes probables de crash :"

echo ""
echo "1. VÉRIFICATION AndroidManifest.xml"
grep -n "activity\|service\|permission" app/src/main/AndroidManifest.xml | head -10

echo ""
echo "2. VÉRIFICATION MainActivity"
head -20 app/src/main/java/com/magiccontrol/MainActivity.kt

echo ""
echo "3. VÉRIFICATION Application class"
head -15 app/src/main/java/com/magiccontrol/MagicControlApplication.kt

echo ""
echo "📱 SOLUTION RAPIDE : Essayer de commenter temporairement les services"
echo "   pour voir si l'Activity principale s'ouvre"
