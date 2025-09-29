#!/bin/bash
echo "🗑️ SUPPRESSION MESSAGE SEULEMENT - POSITIONS GARDÉES"

# 1. Supprimer seulement le string welcome_message
echo "=== SUPPRESSION STRING SEULEMENT ==="
cat > app/src/main/res/values/strings.xml << 'STRINGS'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">MagicControl</string>
    <string name="logo_desc">Logo MagicControl</string>
    <string name="voice_button_desc">Bouton de commande vocale</string>
    <string name="launch_app">Lancer l\'application</string>
    <string name="accessibility_service_label">Service d\'accessibilité MagicControl</string>
    
    <!-- Navigation -->
    <string name="home">Accueil</string>
    <string name="apps">Applications</string>
    <string name="commands">Commandes</string>
    <string name="settings">Paramètres</string>
    <string name="help">Aide</string>
    <string name="about">À propos</string>
    
    <!-- Messages -->
    <string name="listening">Écoute en cours…</string>
    <string name="processing">Traitement…</string>
    <string name="error_audio">Erreur microphone</string>
    <string name="success_command">Commande exécutée</string>
    
    <!-- Commandes système -->
    <string name="volume_up">Volume augmenté</string>
    <string name="volume_down">Volume baissé</string>
    <string name="wifi_on">Wifi activé</string>
    <string name="wifi_off">Wifi désactivé</string>
    <string name="bluetooth_on">Bluetooth activé</string>
    <string name="bluetooth_off">Bluetooth désactivé</string>
    <string name="go_home">Retour à l\'accueil</string>
    <string name="go_back">Retour</string>
</resources>
STRINGS

# 2. Garder le TextView mais le laisser vide
echo ""
echo "=== GARDER TEXTVIEW MAIS VIDER ==="
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

    <!-- Texte d'état - MAINTENANT VIDE -->
    <TextView
        android:id="@+id/status_text"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="16dp"
        android:text=""  <!-- VIDÉ -->
        android:textColor="@color/text_secondary"
        android:textSize="16sp"
        app:layout_constraintTop_toBottomOf="@id/logo"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent" />

    <!-- Bouton vocal STUDIO - POSITION CONSERVÉE -->
    <ImageButton
        android:id="@+id/voice_button"
        android:layout_width="100dp"
        android:layout_height="100dp"
        android:layout_marginTop="48dp"
        android:src="@drawable/ic_mic_studio"
        android:background="?attr/selectableItemBackgroundBorderless"
        android:contentDescription="@string/voice_button_desc"
        app:layout_constraintTop_toBottomOf="@id/status_text"  <!-- TOUJOURS SOUS status_text -->
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent" />

    <!-- Bouton des paramètres - POSITION CONSERVÉE -->
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

echo "✅ MESSAGE SUPPRIMÉ - POSITIONS CONSERVÉES!"
echo "📊 Résultat:"
echo "   - ✅ String welcome_message supprimé"
echo "   - ✅ TextView status_text gardé mais vide"
echo "   - ✅ Logo position inchangée"
echo "   - ✅ Bouton micro position inchangée"
echo "   - ✅ Bouton paramètres position inchangée"
echo "   - ✅ Toutes les margins conservées"
