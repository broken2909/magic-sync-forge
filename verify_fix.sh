#!/bin/bash
echo "🔍 VÉRIFICATION DE LA CORRECTION SPÉCIFIQUE..."

# 1. Vérifier que le fichier corrigé est valide
echo "📱 Vérification activity_main.xml..."
xmllint --noout app/src/main/res/layout/activity_main.xml && echo "✅ XML valide" || echo "❌ XML invalide"

# 2. Vérifier que les IDs référencés existent dans strings.xml
echo "📝 Vérification des références strings..."
grep -o 'android:text="@string/[^"]*"' app/src/main/res/layout/activity_main.xml | sed 's/.*@string\///' | sed 's/"//' | while read string_ref; do
    if grep -q "name=\"$string_ref\"" app/src/main/res/values/strings.xml; then
        echo "✅ Référence string: $string_ref"
    else
        echo "❌ Référence manquante: $string_ref"
    fi
done

# 3. Vérifier que les couleurs référencées existent
echo "🎨 Vérification des références colors..."
grep -o 'android:.*Color="@color/[^"]*"' app/src/main/res/layout/activity_main.xml | sed 's/.*@color\///' | sed 's/"//' | while read color_ref; do
    if grep -q "name=\"$color_ref\"" app/src/main/res/values/colors.xml; then
        echo "✅ Référence color: $color_ref"
    else
        echo "❌ Référence manquante: $color_ref"
    fi
done

# 4. Vérifier la structure globale
echo "📊 Structure du layout corrigé:"
grep -E "(TextView|ImageButton|Button|Toolbar|ImageView)" app/src/main/res/layout/activity_main.xml | head -10

echo "✅ Vérification terminée"
