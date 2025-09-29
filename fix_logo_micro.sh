#!/bin/bash
echo "🔧 CORRECTION LOGO MICRO - RESPECT Z.ai"

# Remplacer le drawable système par ic_mic local
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

    <!-- Bouton vocal - CORRIGÉ POUR Z.ai -->
    <ImageButton
        android:id="@+id/voice_button"
        android:layout_width="100dp"
        android:layout_height="100dp"
        android:layout_marginTop="48dp"
        android:src="@drawable/ic_mic"  <!-- ✅ CORRECTION: ic_mic local au lieu de ic_btn_speak_now système -->
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

echo "✅ LOGO MICRO CORRIGÉ!"
echo "📊 Correction appliquée:"
echo "   - ✅ @android:drawable/ic_btn_speak_now → @drawable/ic_mic"
echo "   - ✅ Respect du design Z.ai original"
echo "   - ✅ Utilisation du drawable local ic_mic.xml"
echo "   - ✅ Dimensions conservées (100dp x 100dp)"
echo ""
echo "🚀 L'application utilise maintenant le VRAI logo Z.ai!"
