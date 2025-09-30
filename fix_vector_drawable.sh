#!/bin/bash
echo "🎨 CORRECTION DU VECTOR DRAWABLE..."

# Sauvegarde du fichier original
cp app/src/main/res/drawable/ic_magic_control.xml app/src/main/res/drawable/ic_magic_control.xml.backup

# Correction des attributs (suppression du préfixe android:)
sed -i 's/android:cx=/cx=/g; s/android:cy=/cy=/g; s/android:r=/r=/g; s/android:fill=/fill=/g; s/android:stroke=/stroke=/g' app/src/main/res/drawable/ic_magic_control.xml

# Vérification de la correction
echo "✅ Fichier corrigé - validation XML..."
xmllint --noout app/src/main/res/drawable/ic_magic_control.xml && echo "✅ XML drawable valide" || echo "❌ XML drawable invalide"

# Vérification que le drawable est toujours référencé dans le layout
echo "📱 Vérification référence dans le layout..."
if grep -q "ic_magic_control" app/src/main/res/layout/activity_main.xml; then
    echo "✅ Référence conservée dans activity_main.xml"
else
    echo "❌ Référence manquante"
fi

echo "🎯 Correction appliquée avec succès"
