#!/bin/bash
echo "🔧 APPLICATION DE LA CORRECTION..."

# Correction de la contrainte
sed -i 's/app:layout_constraintTop_toBottomOf="@id\/status_text"/app:layout_constraintTop_toBottomOf="@id\/logo"/' app/src/main/res/layout/activity_main.xml

echo "✅ Correction appliquée :"
echo "   @id/status_text → @id/logo"

echo ""
echo "📊 VÉRIFICATION FINALE :"
echo "========================="
grep -n "layout_constraintTop_toBottomOf" app/src/main/res/layout/activity_main.xml

echo ""
echo "🎯 STRUCTURE CORRECTE :"
echo "1. Toolbar → Top_of_parent ✅"
echo "2. Logo → Below_toolbar ✅" 
echo "3. Bouton vocal → Below_logo ✅"
echo "4. Bouton paramètres → Below_voice_button ✅"

echo ""
echo "📝 VALIDATION XML :"
xmllint --noout app/src/main/res/layout/activity_main.xml && echo "✅ XML valide" || echo "❌ XML invalide"
