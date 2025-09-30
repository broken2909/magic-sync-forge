#!/bin/bash
echo "🔍 ANALYSE DÉTAILLÉE DE activity_main.xml"

echo "📊 Contenu autour de la ligne 47:"
sed -n '40,55p' app/src/main/res/layout/activity_main.xml

echo ""
echo "🎯 Vérification des IDs déclarés:"
grep -n 'android:id="@+id/' app/src/main/res/layout/activity_main.xml

echo ""
echo "📝 Validation XML:"
xmllint --noout app/src/main/res/layout/activity_main.xml && echo "✅ XML valide" || echo "❌ XML invalide"
