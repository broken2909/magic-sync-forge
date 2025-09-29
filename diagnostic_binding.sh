#!/bin/bash
echo "🔍 DIAGNOSTIC COMPLET DATABINDING"

# 1. Vérifier build.gradle actuel
echo "=== BUILD.GRADLE ACTUEL ==="
grep -A5 -B5 "dataBinding\|viewBinding" app/build.gradle

# 2. Vérifier le layout activity_main.xml
echo ""
echo "=== LAYOUT ACTIVITY_MAIN ==="
head -5 app/src/main/res/layout/activity_main.xml

# 3. Vérifier si databinding est généré
echo ""
echo "=== DOSSIERS BUILD ==="
find app/build -type d -name "*generated*" 2>/dev/null | head -10

# 4. Solution temporaire : utiliser findViewById
echo ""
echo "🎯 SOLUTION TEMPORAIRE:"
echo "Remplacer databinding par findViewById le temps de régler le problème"
