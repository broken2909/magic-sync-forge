#!/bin/bash
echo "🔍 VÉRIFICATION SUPPRESSION COMPLÈTE"

# Vérifier que le message guidance n'existe nulle part
echo ""
echo "📋 RECHERCHE MESSAGE GUIDANCE DANS TOUT LE PROJET"
MESSAGE_FOUND=false

# Rechercher le message spécifique
if grep -r "activation manuelle dans les paramètres d'accessibilité" app/src/main/java/ > /dev/null 2>&1; then
    echo "❌ MESSAGE TROUVÉ DANS :"
    grep -r "activation manuelle dans les paramètres d'accessibilité" app/src/main/java/
    MESSAGE_FOUND=true
else
    echo "✅ MESSAGE GUIDANCE SUPPRIMÉ DE TOUS LES FICHIERS JAVA/KOTLIN"
fi

# Vérifier FirstLaunchWelcome spécifiquement
echo ""
echo "📋 CONTENU FIRSTLAUNCHWELCOME ACTUEL"
grep -A 5 -B 5 "TTSManager.speak" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt

# Vérifier WakeWordService
echo ""
echo "📋 MESSAGE DANS WAKE WORDSERVICE"
grep "Dites le mot clé" app/src/main/java/com/magiccontrol/service/WakeWordService.kt

if [ "$MESSAGE_FOUND" = false ]; then
    echo ""
    echo "🎯 ÉTAT : MESSAGE GUIDANCE COMPLÈTEMENT SUPPRIMÉ"
    echo "✅ Prêt pour l'ajout du message isolé au bon endroit"
else
    echo ""
    echo "⚠️  ATTENTION : MESSAGE GUIDANCE PRÉSENT AILLEURS"
fi
