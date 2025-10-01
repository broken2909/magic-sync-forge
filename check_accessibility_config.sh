#!/bin/bash
echo "🔍 VÉRIFICATION CONFIGURATION ACCESSIBILITÉ"

# 1. Vérifier service accessibilité dans AndroidManifest
echo ""
echo "📋 1. SERVICE ACCESSIBILITÉ ANDROIDMANIFEST"
grep -A 10 "MagicAccessibilityService" app/src/main/AndroidManifest.xml

# 2. Vérifier configuration XML accessibilité
echo ""
echo "📋 2. CONFIGURATION XML ACCESSIBILITÉ"
if [ -f "app/src/main/res/xml/accessibility_service_config.xml" ]; then
    echo "✅ Fichier config trouvé"
    cat app/src/main/res/xml/accessibility_service_config.xml
else
    echo "❌ Fichier config manquant"
fi

# 3. Vérifier MagicAccessibilityService
echo ""
echo "📋 3. MAGICACCESSIBILITYSERVICE"
if [ -f "app/src/main/java/com/magiccontrol/accessibility/MagicAccessibilityService.kt" ]; then
    echo "✅ Service trouvé"
    grep -n "GLOBAL_ACTION_BACK\|GLOBAL_ACTION_HOME" app/src/main/java/com/magiccontrol/accessibility/MagicAccessibilityService.kt
else
    echo "❌ Service manquant"
fi

echo ""
echo "🔍 VÉRIFICATION TERMINÉE"
