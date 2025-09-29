#!/bin/bash
echo "🔍 RECHERCHE APPROCHE BIENVENUE ORIGINALE"

# 1. Vérifier MainActivity actuel
echo "=== MAINACTIVITY ACTUEL ==="
grep -n "welcome\|Welcome\|bienvenue\|Bienvenue" app/src/main/java/com/magiccontrol/MainActivity.kt

# 2. Vérifier TTSManager
echo ""
echo "=== TTSManager ==="
grep -n "welcome\|Welcome\|bienvenue\|Bienvenue" app/src/main/java/com/magiccontrol/tts/TTSManager.kt 2>/dev/null || echo "Non trouvé dans TTSManager"

# 3. Vérifier strings.xml
echo ""
echo "=== STRINGS.XML ==="
grep "welcome_message" app/src/main/res/values/strings.xml

# 4. Chercher dans les commits Git
echo ""
echo "=== COMMITS GIT ==="
git log --oneline -10 | grep -i "welcome\|bienvenue" | head -5

echo ""
echo "🎯 L'approche originale était probablement:"
echo "   - Le string 'welcome_message' dans strings.xml"
echo "   - Lu directement par TTS sans gestion de langue"
echo "   - Ou détection automatique par le système TTS Android"
