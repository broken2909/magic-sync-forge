#!/bin/bash
echo "🔍 VÉRIFICATION LOGO MICRO CODE Z.ai vs APPLICATION"

# 1. Chercher le logo micro dans les drawables
echo "=== FICHIERS DRAWABLE MICRO ==="
find app/src/main/res/drawable* -name "*mic*" -o -name "*micro*" -o -name "*voice*" | head -10

# 2. Vérifier le layout activity_main pour la référence
echo ""
echo "=== RÉFÉRENCE DANS LAYOUT ==="
grep -n "voice_button" app/src/main/res/layout/activity_main.xml

# 3. Vérifier le bouton vocal dans MainActivity
echo ""
echo "=== BOUTON DANS MAINACTIVITY ==="
grep -n "voice_button" app/src/main/java/com/magiccontrol/MainActivity.kt

# 4. Comparer avec le code Z.ai original (extrait du script 7)
echo ""
echo "=== CODE Z.ai ORIGINAL (script 7) ==="
echo "Dans le script Z.ai, le bouton vocal était:"
echo "<ImageButton"
echo "    android:id=\"@+id/voice_button\""
echo "    android:layout_width=\"100dp\""
echo "    android:layout_height=\"100dp\""
echo "    android:src=\"@drawable/ic_mic\""
echo "    android:background=\"?attr/selectableItemBackgroundBorderless\""
echo "    android:contentDescription=\"@string/voice_button_desc\" />"

# 5. Vérifier si ic_mic existe
echo ""
echo "=== PRÉSENCE IC_MIC ==="
find app/src/main/res -name "ic_mic*" | head -5

# 6. Vérifier les strings
echo ""
echo "=== STRING VOICE_BUTTON_DESC ==="
grep "voice_button_desc" app/src/main/res/values/strings.xml
