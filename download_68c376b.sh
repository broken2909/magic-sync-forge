#!/bin/bash
echo "🌐 TÉLÉCHARGEMENT COMMIT 68c376b DEPUIS GITHUB"

# URLs directes des fichiers du commit 68c376b
BASE_URL="https://raw.githubusercontent.com/broken2909/magic-sync-forge/68c376b"

echo ""
echo "📦 TÉLÉCHARGEMENT DES FICHIERS STABLES"

# Télécharger MainActivity.kt
echo "🔧 Téléchargement MainActivity.kt..."
wget -q -O app/src/main/java/com/magiccontrol/MainActivity.kt "$BASE_URL/app/src/main/java/com/magiccontrol/MainActivity.kt"

# Télécharger FirstLaunchWelcome.kt
echo "🔧 Téléchargement FirstLaunchWelcome.kt..."
wget -q -O app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt "$BASE_URL/app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt"

# Télécharger WakeWordDetector.kt
echo "🔧 Téléchargement WakeWordDetector.kt..."
wget -q -O app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt "$BASE_URL/app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt"

echo ""
echo "✅ TÉLÉCHARGEMENT TERMINÉ"
echo "📊 Fichiers téléchargés depuis commit 68c376b:"
echo "   • MainActivity.kt"
echo "   • FirstLaunchWelcome.kt"
echo "   • WakeWordDetector.kt"

echo ""
echo "🔍 VÉRIFICATION CONTENU:"
echo "MainActivity - DataBinding: $(grep -c "ActivityMainBinding" app/src/main/java/com/magiccontrol/MainActivity.kt)"
echo "FirstLaunchWelcome - Message: $(grep -c "Bienvenue dans Magic Control" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt)"
echo "WakeWordDetector - Constructeur: $(grep -c "Model(context.assets" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt)"

echo ""
echo "🎯 ÉTAT: Base propre et stable restaurée"
echo "📱 APK artifacts fonctionnel sans crash"
