#!/bin/bash

echo "🚀 Démarrage du build MagicControl..."
echo "📦 Nettoyage..."
./gradlew clean

echo "🔨 Compilation..."
if ./gradlew assembleDebug; then
    echo "✅ BUILD RÉUSSI"
    
    # Vérifier où est l'APK
    if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
        echo "📱 APK trouvé: app/build/outputs/apk/debug/app-debug.apk"
        ls -lh app/build/outputs/apk/debug/app-debug.apk
    else
        echo "🔍 Recherche alternative de l'APK..."
        find . -name "*.apk" -type f
    fi
else
    echo "❌ BUILD ÉCHOUÉ"
    exit 1
fi
