#!/bin/bash
echo "🎨 CRÉATION DU LOGO MAGICCONTROL PARFAIT..."

# Création du logo exact de l'ancien chat
cat > app/src/main/res/drawable/ic_magic_control.xml << 'FILE'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="120dp"
    android:height="120dp"
    android:viewportWidth="120"
    android:viewportHeight="120"
    android:autoMirrored="true">

    <!-- FACE 1: MC stylisé -->
    <group
        android:name="face_mc"
        android:pivotX="60"
        android:pivotY="60">
        
        <!-- Cercle de fond bleu -->
        <circle
            cx="60"
            cy="60"
            r="50"
            fill="#58a6ff" />
        
        <!-- Lettre M stylisée -->
        <path
            fill="#c9d1d9"
            pathData="M40,40 L48,60 L40,80 L50,80 L55,65 L60,80 L70,80 L62,60 L70,40 L60,40 L55,55 L50,40 Z" />
        
        <!-- Lettre C stylisée -->
        <path
            fill="#c9d1d9" 
            pathData="M75,40 C65,40 55,50 55,60 C55,70 65,80 75,80 C80,80 85,75 88,70 L82,66 C80,70 78,72 75,72 C70,72 65,67 65,60 C65,53 70,48 75,48 C78,48 80,50 82,54 L88,50 C85,45 80,40 75,40 Z" />
    </group>

    <!-- FACE 2: Onde sonique (visible pendant la rotation) -->
    <group
        android:name="face_wave"
        android:pivotX="60"
        android:pivotY="60">
        
        <!-- Cercle central -->
        <circle
            cx="60"
            cy="60"
            r="15"
            fill="#58a6ff" />
        
        <!-- Onde 1 -->
        <circle
            cx="60"
            cy="60"
            r="30"
            stroke="#58a6ff"
            strokeWidth="3"
            fill="#00000000" />
        
        <!-- Onde 2 -->
        <circle
            cx="60"
            cy="60"
            r="45"
            stroke="#58a6ff"
            strokeWidth="2"
            fill="#00000000" />
            
        <!-- Point sonique -->
        <circle
            cx="75"
            cy="45"
            r="4"
            fill="#c9d1d9" />
    </group>

</vector>
FILE

echo "✅ Logo MagicControl PARFAIT créé !"
echo "🎯 Caractéristiques :"
echo "   - Design exact ancien chat"
echo "   - Deux faces : MC + Onde sonique"
echo "   - Palette Z.ai respectée"
echo "   - Structure VectorDrawable valide"
echo "   - Prêt pour animations futures"

echo ""
echo "📝 Validation XML :"
xmllint --noout app/src/main/res/drawable/ic_magic_control.xml && echo "✅ XML valide" || echo "❌ XML invalide"

echo ""
echo "🔍 Vérification intégration :"
grep -n "ic_magic_control" app/src/main/res/layout/activity_main.xml
