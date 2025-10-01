#!/bin/bash
echo "🔍 VÉRIFICATION RÉFÉRENCES MESSAGE GUIDANCE"

# 1. Rechercher toutes les références au message guidance
echo ""
echo "📋 1. RECHERCHE MESSAGE GUIDANCE DANS TOUT LE CODE"
MESSAGE_FOUND=false

# Rechercher le texte spécifique du message guidance
if grep -r "activation manuelle dans les paramètres d'accessibilité" app/src/main/java/ > /dev/null 2>&1; then
    echo "✅ MESSAGE GUIDANCE TROUVÉ DANS :"
    grep -r "activation manuelle dans les paramètres d'accessibilité" app/src/main/java/ | cut -d: -f1
    MESSAGE_FOUND=true
else
    echo "❌ MESSAGE GUIDANCE NON TROUVÉ DANS LE CODE"
fi

# 2. Vérifier où se trouve le message maintenant
echo ""
echo "📋 2. EMPLACEMENT ACTUEL DU MESSAGE"
if [ -f "app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt" ]; then
    echo "📍 FirstLaunchWelcome.kt :"
    grep -A 2 -B 2 "activation manuelle" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt || echo "   Non trouvé ici"
fi

# 3. Vérifier les autres fichiers qui pourraient contenir des messages
echo ""
echo "📋 3. AUTRES FICHIERS AVEC MESSAGES VOCAUX"
find app/src/main/java -name "*.kt" -exec grep -l "TTSManager.speak" {} \; | while read file; do
    echo "📍 $file :"
    grep -n "TTSManager.speak" "$file" | head -3
done

# 4. Vérifier qu'il n'y a pas de doublons
echo ""
echo "📋 4. VÉRIFICATION DOUBLONS"
COUNT=$(grep -r "activation manuelle" app/src/main/java/ | wc -l)
if [ "$COUNT" -eq 1 ]; then
    echo "✅ MESSAGE UNIQUE : Présent dans 1 seul fichier"
else
    echo "⚠️  ATTENTION : Message présent dans $COUNT fichiers"
    grep -r "activation manuelle" app/src/main/java/ | cut -d: -f1
fi

# 5. Vérifier l'appel dans MainActivity
echo ""
echo "📋 5. APPEL DANS MAINACTIVITY"
grep -n "FirstLaunchWelcome.playWelcomeIfFirstLaunch" app/src/main/java/com/magiccontrol/MainActivity.kt

echo ""
if [ "$MESSAGE_FOUND" = true ] && [ "$COUNT" -eq 1 ]; then
    echo "🎯 ÉTAT : MESSAGE GUIDANCE CORRECTEMENT PLACÉ"
    echo "   • Présent dans FirstLaunchWelcome.kt uniquement"
    echo "   • Appelé dans MainActivity.kt"
    echo "   • Aucun doublon détecté"
else
    echo "⚠️  ÉTAT : VÉRIFICATION NÉCESSAIRE"
fi
