#!/bin/bash

echo "🎯 AMÉLIORATION DÉTECTION VOCALE - SEUIL PLUS TOLÉRANT"

# Chemin absolu du projet
PROJECT_DIR="/data/data/com.termux/files/home/magic-sync-forge"
cd "$PROJECT_DIR"

# Fichier à modifier
FILE="app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt"
BACKUP="${FILE}.backup.$(date +%Y%m%d_%H%M%S)"

echo "📁 Dossier projet: $PROJECT_DIR"
echo "📁 Fichier cible: $FILE"
echo "💾 Sauvegarde: $BACKUP"

# Vérifier si le fichier existe
if [ ! -f "$FILE" ]; then
    echo "❌ Fichier non trouvé: $FILE"
    exit 1
fi

# Créer une sauvegarde
cp "$FILE" "$BACKUP"
echo "✅ Sauvegarde créée: $BACKUP"

# Afficher le seuil actuel
echo ""
echo "🔍 SEUIL ACTUEL:"
grep -n "audioLevel.*1000\|1000" "$FILE" || echo "Aucun seuil 1000 trouvé"

# Modifier le seuil de 1000 à 500 pour plus de tolérance
echo ""
echo "🔄 MODIFICATION: 1000 → 500 (plus tolérant)"
sed -i 's/audioLevel > 1000/audioLevel > 500/g' "$FILE"
sed -i 's/1000/500/g' "$FILE"  # Pour les autres occurrences

# Vérifier les modifications
echo ""
echo "✅ SEUIL MODIFIÉ:"
grep -n "audioLevel.*500\|500" "$FILE" | head -10

# Vérification syntaxique basique
echo ""
echo "🔍 VÉRIFICATION SYNTAXE:"
if grep -q "audioLevel > 500" "$FILE"; then
    echo "✅ Modification appliquée avec succès"
else
    echo "❌ Modification non appliquée"
    exit 1
fi

echo ""
echo "🎯 RÉSUMÉ DES CHANGEMENTS:"
echo "   - Seuil audio réduit de 1000 à 500"
echo "   - Détection plus sensible aux sons faibles"
echo "   - Meilleure tolérance pour environnements bruyants"

echo ""
echo "📝 PROCHAINES ÉTAPES:"
echo "   1. Commit et push sur GitHub"
echo "   2. Tester l'APK généré"
echo "   3. Ajuster si nécessaire (250 ou 750)"

echo "✅ Script terminé - Prêt pour commit!"
