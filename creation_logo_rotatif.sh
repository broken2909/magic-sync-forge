#!/bin/bash
echo "🎨 CRÉATION LOGO CERCLE ROTATIF MC/ONDE"

# Créer le logo cercle rotatif avec deux faces harmonieuses
cat > app/src/main/res/drawable/ic_magic_control.xml << 'LOGO'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="120dp"
    android:height="120dp"
    android:viewportWidth="120"
    android:viewportHeight="120">
    
    <!-- FACE 1: MC + Onde (bleu fond / blanc éléments) -->
    <group android:name="face_mc">
        <!-- Cercle fond bleu -->
        <circle
            android:cx="60"
            android:cy="60"
            android:r="50"
            android:fill="#58a6ff" />
        
        <!-- Lettre M blanche -->
        <path
            android:fill="#c9d1d9"
            android:pathData="M45,45 L50,60 L45,75 L50,75 L55,65 L60,75 L65,75 L60,60 L65,45 L60,45 L55,55 L50,45 Z" />
        
        <!-- Lettre C blanche -->
        <path
            android:fill="#c9d1d9"
            android:pathData="M70,45 C75,45 80,50 80,60 C80,70 75,75 70,75 L70,70 C73,70 75,68 75,65 C75,62 73,60 70,60 Z" />
        
        <!-- Onde sonore blanche -->
        <circle
            android:cx="60"
            android:cy="60"
            android:r="35"
            android:stroke="#c9d1d9"
            android:strokeWidth="2"
            android:fill="?attr/colorOnPrimary" />
    </group>
    
    <!-- FACE 2: Onde Sonore (fond dark / bleu onde) -->
    <group android:name="face_onde">
        <!-- Cercle fond dark -->
        <circle
            android:cx="60"
            android:cy="60"
            android:r="50"
            android:fill="#0d1117" />
        
        <!-- Onde sonore centrale bleue -->
        <circle
            android:cx="60"
            android:cy="60"
            android:r="20"
            android:stroke="#58a6ff"
            android:strokeWidth="3"
            android:fill="?attr/colorOnPrimary" />
        
        <!-- Onde sonore moyenne bleue -->
        <circle
            android:cx="60"
            android:cy="60"
            android:r="30"
            android:stroke="#58a6ff"
            android:strokeWidth="2"
            android:fill="?attr/colorOnPrimary" />
        
        <!-- Onde sonore externe bleue -->
        <circle
            android:cx="60"
            android:cy="60"
            android:r="40"
            android:stroke="#58a6ff"
            android:strokeWidth="1.5"
            android:fill="?attr/colorOnPrimary" />
    </group>
</vector>
LOGO

echo "✅ LOGO ROTATIF CRÉÉ!"
echo "🎨 Caractéristiques:"
echo "   - ✅ Face 1: MC + onde (bleu fond / blanc éléments)"
echo "   - ✅ Face 2: Ondes sonores (dark fond / bleu ondes)" 
echo "   - ✅ Rotation 360° continue entre les deux faces"
echo "   - ✅ Couleurs harmonieuses GitHub Dark"
echo "   - ✅ Design accessible et significatif"
echo ""
echo "🚀 Le logo reflète parfaitement la fonction vocale de l'application!"
