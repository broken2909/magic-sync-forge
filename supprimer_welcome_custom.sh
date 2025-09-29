#!/bin/bash
echo "🗑️ SUPPRESSION WELCOMEMANAGER PERSONNALISÉ"

# Supprimer le fichier WelcomeManager.kt que j'ai créé
rm app/src/main/java/com/magiccontrol/utils/WelcomeManager.kt

echo "✅ WelcomeManager personnalisé supprimé!"
echo "🔍 Maintenant cherchons l'approche originale..."

# Chercher d'autres approches de bienvenue
find app/src/main/java -name "*.kt" -exec grep -l "welcome\|bienvenue" {} \; | head -10

echo ""
echo "📱 L'approche originale était probablement:"
echo "   - Soit dans MainActivity directement"
echo "   - Soit via TTSManager avec message fixe"
echo "   - Soit via les ressources strings.xml multilingues"
