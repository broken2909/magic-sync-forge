#!/bin/bash
echo "🔍 VÉRIFICATION RISQUE CRASH"

# 1. Vérifier le contenu du string
echo "=== CONTENU WELCOME_MESSAGE ==="
grep "welcome_message" app/src/main/res/values/strings.xml

# 2. Vérifier si TTSManager peut gérer les guillemets
echo ""
echo "=== TTSManager EXISTE ? ==="
find app/src/main/java -name "TTSManager.kt" && echo "✅ TTSManager présent" || echo "❌ TTSManager manquant"

# 3. Vérifier les imports dans MainActivity
echo ""
echo "=== IMPORTS MAINACTIVITY ==="
head -15 app/src/main/java/com/magiccontrol/MainActivity.kt | grep "import"

# 4. Solution alternative : message dédié pour TTS
echo ""
echo "🎯 SOLUTION SANS RISQUE:"
echo "Créer un string dédié pour TTS sans guillemets:"
echo '<string name="welcome_tts">Bienvenue dans MagicControl. Dites Magic pour commencer</string>'
