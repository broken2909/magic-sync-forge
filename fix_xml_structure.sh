#!/bin/bash
echo "🔧 CORRECTION STRUCTURE XML"

# Recréer le fichier correctement structuré
cat > app/src/main/res/values/strings.xml << 'XML'
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
    
    <!-- Welcome messages -->
    <string name="welcome_message">Welcome to your MagicControl voice assistant</string>
</resources>
XML

echo "✅ STRUCTURE CORRIGÉE :"
echo "• Balise </resources> à la fin"
echo "• welcome_message DANS la balise resources"
echo "• Fichier XML bien formé"

echo ""
echo "🔍 VÉRIFICATION :"
cat app/src/main/res/values/strings.xml | tail -5
