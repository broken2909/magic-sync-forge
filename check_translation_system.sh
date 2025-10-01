#!/bin/bash
echo "🔍 VÉRIFICATION SYSTÈME TRADUCTION MULTI-LANGUE"

# 1. Vérifier les strings.xml multi-langues
echo ""
echo "📋 1. FICHIERS STRINGS.XML PAR LANGUE"
find app/src/main/res -name "strings.xml" | head -10

# 2. Vérifier ProfessionalTranslationManager
echo ""
echo "📋 2. PROFESSIONALTRANSLATIONMANAGER"
if [ -f "app/src/main/java/com/magiccontrol/utils/ProfessionalTranslationManager.kt" ]; then
    echo "✅ Fichier trouvé"
    grep -n "class ProfessionalTranslationManager\|fun.*translate\|object.*Translation" app/src/main/java/com/magiccontrol/utils/ProfessionalTranslationManager.kt
else
    echo "❌ Fichier manquant"
fi

# 3. Vérifier getCurrentLanguage dans PreferencesManager
echo ""
echo "📋 3. GETCURRENTLANGUAGE IMPLÉMENTATION"
if [ -f "app/src/main/java/com/magiccontrol/utils/PreferencesManager.kt" ]; then
    echo "✅ PreferencesManager trouvé"
    grep -A 10 "getCurrentLanguage" app/src/main/java/com/magiccontrol/utils/PreferencesManager.kt
else
    echo "❌ PreferencesManager manquant"
fi

# 4. Vérifier structure strings.xml principal
echo ""
echo "📋 4. CONTENU STRINGS.XML PRINCIPAL"
if [ -f "app/src/main/res/values/strings.xml" ]; then
    echo "✅ strings.xml principal trouvé"
    grep -c "string name" app/src/main/res/values/strings.xml | xargs echo "Nombre de strings:"
    grep "accessibility\|activation\|paramètres" app/src/main/res/values/strings.xml | head -5
else
    echo "❌ strings.xml principal manquant"
fi

# 5. Vérifier autres langues
echo ""
echo "📋 5. LANGUES SUPPORTÉES"
find app/src/main/res -name "strings.xml" -exec dirname {} \; | xargs -I {} basename {} | sort | uniq

echo ""
echo "🔍 VÉRIFICATION TERMINÉE"
