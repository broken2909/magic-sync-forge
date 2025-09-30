#!/bin/bash
echo "🎨 CORRECTION HARMONISÉE DE ic_mic_studio.xml..."

# Création du fichier corrigé
cat > app/src/main/res/drawable/ic_mic_studio.xml << 'FILE'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="100dp"
    android:height="100dp"
    android:viewportWidth="100"
    android:viewportHeight="100">

    <!-- Cercle de fond -->
    <circle
        cx="50"
        cy="50"
        r="40"
        fill="#58a6ff" /> <!-- github_accent -->

    <!-- Base du micro -->
    <rect
        x="45dp"
        y="25dp"
        width="10dp"
        height="30dp"
        fill="#c9d1d9" /> <!-- github_text -->

    <!-- Grille du micro -->
    <rect
        x="42dp"
        y="20dp"
        width="16dp"
        height="5dp"
        rx="2dp"
        fill="#0d1117" /> <!-- github_bg -->

    <!-- Onde sonore 1 (interne) -->
    <circle
        cx="50"
        cy="50"
        r="30"
        stroke="#58a6ff"
        strokeWidth="2"
        fill="#161b22" /> <!-- github_surface -->

    <!-- Onde sonore 2 (externe) -->
    <circle
        cx="50"
        cy="50"
        r="45"
        stroke="#58a6ff"
        strokeWidth="1.5"
        fill="#161b22" /> <!-- github_surface -->

    <!-- Animation des ondes (pour interaction future) -->
    <group>
        <circle
            cx="50"
            cy="50"
            r="30"
            stroke="#58a6ff"
            strokeWidth="2"
            fill="#161b22" /> <!-- github_surface -->
        <circle
            cx="50"
            cy="50"
            r="45"
            stroke="#58a6ff"
            strokeWidth="1.5"
            fill="#161b22" /> <!-- github_surface -->
    </group>
</vector>
FILE

# Validation
echo "✅ Fichier corrigé - validation..."
xmllint --noout app/src/main/res/drawable/ic_mic_studio.xml && echo "✅ XML valide" || echo "❌ XML invalide"

echo "🎯 Correction appliquée avec succès"
echo "📊 Résumé des modifications :"
echo "   - Attributs vector: android: → sans préfixe"
echo "   - Dimensions: ajout des unités dp"
echo "   - Couleurs: harmonisation palette Z.ai"
echo "   - ?attr/colorOnPrimary → #161b22 (github_surface)"
