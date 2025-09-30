#!/bin/bash
echo "🗑️ SUPPRESSION DE LA RÉFÉRENCE WELCOME_MESSAGE DU LAYOUT..."

# Sauvegarde du fichier original
cp app/src/main/res/layout/activity_main.xml app/src/main/res/layout/activity_main.xml.backup

# Suppression du TextView qui référence welcome_message
sed -i '/<TextView.*android:id="@+id\/status_text".*/,/\/>/d' app/src/main/res/layout/activity_main.xml

# Vérification que la référence a été supprimée
if ! grep -q "welcome_message" app/src/main/res/layout/activity_main.xml; then
    echo "✅ Référence welcome_message supprimée du layout"
else
    echo "❌ Échec de la suppression"
    exit 1
fi

# Vérification que le XML est toujours valide
xmllint --noout app/src/main/res/layout/activity_main.xml && echo "✅ XML toujours valide après modification" || echo "❌ XML invalide après modification"

echo "📊 Layout final sans welcome_message:"
grep -E "(TextView|ImageButton|Button|Toolbar|ImageView)" app/src/main/res/layout/activity_main.xml
