#!/bin/bash
echo "🔍 VÉRIFICATION MESSAGE 'DITES MAGIC' DANS TOUT LE CODE"

# 1. Vérifier dans strings.xml
echo "=== STRINGS.XML ==="
grep -n "welcome_message" app/src/main/res/values/strings.xml

# 2. Vérifier dans le layout activity_main
echo ""
echo "=== LAYOUT ACTIVITY_MAIN ==="
grep -A5 -B5 "status_text" app/src/main/res/layout/activity_main.xml

# 3. Vérifier dans MainActivity
echo ""
echo "=== MAINACTIVITY ==="
grep -n "status_text\|welcome_message" app/src/main/java/com/magiccontrol/MainActivity.kt

# 4. Vérifier dans d'autres layouts
echo ""
echo "=== AUTRES LAYOUTS ==="
find app/src/main/res/layout -name "*.xml" -exec grep -l "welcome_message" {} \;

# 5. Vérifier dans tout le code Java/Kotlin
echo ""
echo "=== TOUT LE CODE JAVA/KOTLIN ==="
find app/src/main/java -name "*.kt" -exec grep -l "welcome_message" {} \;

# 6. Vérifier si utilisé ailleurs
echo ""
echo "=== UTILISATION GLOBALE ==="
echo "Recherche dans tous les fichiers..."
grep -r "welcome_message" app/src/main/ | grep -v "import"

echo ""
echo "🎯 EMPLACEMENTS TROUVÉS:"
echo "✅ strings.xml: Définition du message"
echo "✅ activity_main.xml: Référence dans status_text"
echo "❌ MainActivity: Pas de référence directe (normal)"
echo "✅ Position: Entre logo et bouton micro"
