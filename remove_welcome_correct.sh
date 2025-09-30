#!/bin/bash
echo "🗑️ SUPPRESSION CORRECTE DU TEXTVIEW WELCOME_MESSAGE..."

# Méthode plus robuste : créer un nouveau fichier sans le TextView
grep -n "status_text" app/src/main/res/layout/activity_main.xml
echo "📝 Recherche des lignes à supprimer..."

# Création du nouveau fichier sans le bloc TextView
awk '
/<!-- Texte d.état -->/ { skip=1 }
/\/>/ && skip==1 { skip=0; next }
skip==0 { print }
' app/src/main/res/layout/activity_main.xml > app/src/main/res/layout/activity_main_new.xml

# Remplacement du fichier
mv app/src/main/res/layout/activity_main_new.xml app/src/main/res/layout/activity_main.xml

# Vérification
if ! grep -q "welcome_message" app/src/main/res/layout/activity_main.xml; then
    echo "✅ Référence welcome_message supprimée avec succès"
else
    echo "❌ Échec - tentative manuelle nécessaire"
    # Montrer où se trouve la référence
    grep -n "welcome_message" app/src/main/res/layout/activity_main.xml
fi

# Validation XML
xmllint --noout app/src/main/res/layout/activity_main.xml && echo "✅ XML valide" || echo "❌ XML invalide"

echo "📊 Structure finale:"
grep -E "(TextView|ImageButton|Button|Toolbar|ImageView)" app/src/main/res/layout/activity_main.xml
