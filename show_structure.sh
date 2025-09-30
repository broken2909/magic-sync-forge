#!/bin/bash
echo "🏗️ STRUCTURE COMPLÈTE DU LAYOUT"

echo ""
echo "📱 HIÉRARCHIE DES ÉLÉMENTS :"
echo "=========================================="

# Afficher tous les éléments avec leurs contraintes
grep -E "(Toolbar|ImageView|ImageButton|Button|TextView)" app/src/main/res/layout/activity_main.xml | while read line; do
    if echo "$line" | grep -q "android:id"; then
        id=$(echo "$line" | grep -o 'android:id="@+id/[^"]*"' | sed 's/.*@+id\///' | sed 's/"//')
        echo "🔸 $id"
    fi
done

echo ""
echo "🔗 CONTRAINTES DE POSITIONNEMENT :"
echo "=========================================="

# Afficher les contraintes pour chaque élément
for element in toolbar logo voice_button settings_button; do
    echo "🎯 $element:"
    grep -A5 "android:id=\"@+id/$element\"" app/src/main/res/layout/activity_main.xml | grep "layout_constraint" || echo "   (pas de contraintes trouvées)"
    echo ""
done

echo "📊 RÉSUMÉ DE LA STRUCTURE :"
echo "1. Toolbar (haut)"
echo "2. Logo (en dessous de toolbar)" 
echo "3. Bouton micro (position actuelle ?)"
echo "4. Bouton paramètres (en dessous de bouton micro)"
