#!/bin/bash
echo "🔄 RESTAURATION COMMIT 68c376b - ÉTAT STABLE"

# Créer un backup de l'état actuel avant restauration
echo ""
echo "📦 BACKUP ÉTAT ACTUEL AVANT RESTAURATION"
BACKUP_DIR="backup_before_restore_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

cp app/src/main/java/com/magiccontrol/MainActivity.kt "$BACKUP_DIR/MainActivity.current.kt"
cp app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt "$BACKUP_DIR/FirstLaunchWelcome.current.kt"
cp app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt "$BACKUP_DIR/WakeWordDetector.current.kt"

echo "✅ Backup état actuel créé: $BACKUP_DIR/"

# Restaurer MainActivity depuis le commit 68c376b
echo ""
echo "🔧 RESTAURATION MAINACTIVITY"
git show 68c376b:app/src/main/java/com/magiccontrol/MainActivity.kt > app/src/main/java/com/magiccontrol/MainActivity.kt

# Restaurer FirstLaunchWelcome depuis le commit 68c376b  
echo "🔧 RESTAURATION FIRSTLAUNCHWELCOME"
git show 68c376b:app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt > app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt

# Restaurer WakeWordDetector depuis le backup (version stable)
echo "🔧 RESTAURATION WAKEWORDDETECTOR"
if [ -f "backup_vosk_*/WakeWordDetector.backup.kt" ]; then
    cp backup_vosk_*/WakeWordDetector.backup.kt app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt
else
    git show 68c376b:app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt > app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt
fi

echo ""
echo "✅ RESTAURATION TERMINÉE"
echo "📊 Fichiers restaurés depuis commit 68c376b:"
echo "   • MainActivity.kt"
echo "   • FirstLaunchWelcome.kt" 
echo "   • WakeWordDetector.kt"
echo ""
echo "🔍 VÉRIFICATION:"
echo "MainActivity - DataBinding: $(grep -c "ActivityMainBinding" app/src/main/java/com/magiccontrol/MainActivity.kt)"
echo "FirstLaunchWelcome - Message simple: $(grep -c "Bienvenue dans Magic Control" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt)"
echo "WakeWordDetector - Constructeur: $(grep -c "Model(context.assets" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt)"
