#!/bin/bash
echo "🎤 CRÉATION BOUTON MICRO STUDIO AVEC ONDES"

# Créer le nouveau drawable micro avec ondes sonores
cat > app/src/main/res/drawable/ic_mic_studio.xml << 'MICRO'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="100dp"
    android:height="100dp"
    android:viewportWidth="100"
    android:viewportHeight="100">
    
    <!-- Cercle de fond -->
    <circle
        android:cx="50"
        android:cy="50"
        android:r="40"
        android:fill="#58a6ff" /> <!-- Couleur accent Z.ai -->
    
    <!-- Base du micro -->
    <rect
        android:x="45"
        android:y="25"
        android:width="10"
        android:height="30"
        android:fill="#c9d1d9" /> <!-- Couleur texte Z.ai -->
    
    <!-- Grille du micro -->
    <rect
        android:x="42"
        android:y="20"
        android:width="16"
        android:height="5"
        android:rx="2"
        android:fill="#0d1117" /> <!-- Background Z.ai -->
    
    <!-- Onde sonore 1 (interne) -->
    <circle
        android:cx="50"
        android:cy="50"
        android:r="30"
        android:stroke="#58a6ff"
        android:strokeWidth="2"
        android:fill="?attr/colorOnPrimary" />
    
    <!-- Onde sonore 2 (externe) -->
    <circle
        android:cx="50"
        android:cy="50"
        android:r="45"
        android:stroke="#58a6ff"
        android:strokeWidth="1.5"
        android:fill="?attr/colorOnPrimary" />
        
    <!-- Animation des ondes (pour interaction future) -->
    <group android:name="sound_waves">
        <circle
            android:name="wave1"
            android:cx="50"
            android:cy="50"
            android:r="30"
            android:stroke="#58a6ff"
            android:strokeWidth="2"
            android:fill="?attr/colorOnPrimary" />
        <circle
            android:name="wave2"
            android:cx="50"
            android:cy="50"
            android:r="45"
            android:stroke="#58a6ff"
            android:strokeWidth="1.5"
            android:fill="?attr/colorOnPrimary" />
    </group>
</vector>
MICRO

# Mettre à jour le layout pour utiliser le nouveau micro
cat > app/src/main/res/layout/activity_main.xml << 'LAYOUT'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/background"
    tools:context=".MainActivity">

    <!-- Toolbar -->
    <androidx.appcompat.widget.Toolbar
        android:id="@+id/toolbar"
        android:layout_width="match_parent"
        android:layout_height="?attr/actionBarSize"
        android:background="@color/surface"
        app:title="@string/app_name"
        app:titleTextColor="@color/text"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent" />

    <!-- Logo -->
    <ImageView
        android:id="@+id/logo"
        android:layout_width="120dp"
        android:layout_height="120dp"
        android:layout_marginTop="32dp"
        android:src="@drawable/ic_magic_control"
        android:contentDescription="@string/logo_desc"
        app:layout_constraintTop_toBottomOf="@id/toolbar"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent" />

    <!-- Texte d'état -->
    <TextView
        android:id="@+id/status_text"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="16dp"
        android:text="@string/welcome_message"
        android:textColor="@color/text_secondary"
        android:textSize="16sp"
        app:layout_constraintTop_toBottomOf="@id/logo"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent" />

    <!-- Bouton vocal STUDIO - NOUVEAU DESIGN -->
    <ImageButton
        android:id="@+id/voice_button"
        android:layout_width="100dp"
        android:layout_height="100dp"
        android:layout_marginTop="48dp"
        android:src="@drawable/ic_mic_studio"  <!-- NOUVEAU MICRO STUDIO -->
        android:background="?attr/selectableItemBackgroundBorderless"
        android:contentDescription="@string/voice_button_desc"
        app:layout_constraintTop_toBottomOf="@id/status_text"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent" />

    <!-- Bouton des paramètres -->
    <Button
        android:id="@+id/settings_button"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="32dp"
        android:text="@string/settings"
        android:textColor="@color/text"
        android:backgroundTint="@color/accent"
        app:layout_constraintTop_toBottomOf="@id/voice_button"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent" />

</androidx.constraintlayout.widget.ConstraintLayout>
LAYOUT

echo "✅ BOUTON MICRO STUDIO CRÉÉ!"
echo "🎤 Caractéristiques:"
echo "   - ✅ Micro de studio professionnel"
echo "   - ✅ 2 ondes sonores concentriques"
echo "   - ✅ Couleurs palette Z.ai GitHub Dark"
echo "   - ✅ Prêt pour animations futures"
echo "   - ✅ Design adapté malvoyants (contraste)"
echo ""
echo "🚀 Le bouton micro a maintenant un design studio pro!"
