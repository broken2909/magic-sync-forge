#!/bin/bash
echo "🔧 RETRAIT SÉCURISÉ DE FullRecognitionService DU MANIFEST"

# Création d'une sauvegarde
cp app/src/main/AndroidManifest.xml app/src/main/AndroidManifest.xml.backup

# Retrait de la déclaration FullRecognitionService
cat > app/src/main/AndroidManifest.xml << 'MANIFEST'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MICROPHONE" />

    <application
        android:name=".MagicControlApplication"
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:theme="@style/Theme.MagicControl"
        tools:targetApi="34"
        tools:ignore="GoogleAppIndexingWarning">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTask"
            android:screenOrientation="portrait"
            android:configChanges="keyboardHidden|orientation|screenSize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <!-- Service de détection du mot d'activation -->
        <service
            android:name=".service.WakeWordService"
            android:enabled="true"
            android:exported="false"
            android:foregroundServiceType="microphone" />

        <!-- Service de téléchargement des modèles -->
        <service
            android:name=".service.ModelDownloadService"
            android:enabled="true"
            android:exported="false" />

        <!-- Service d'accessibilité pour les commandes système -->
        <service
            android:name=".accessibility.MagicAccessibilityService"
            android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE"
            android:exported="true"
            android:label="@string/accessibility_service_label">
            <intent-filter>
                <action android:name="android.accessibilityservice.AccessibilityService" />
            </intent-filter>
            <meta-data
                android:name="android.accessibilityservice"
                android:resource="@xml/accessibility_service_config" />
        </service>

    </application>

</manifest>
MANIFEST

echo ""
echo "✅ RETRAIT TERMINÉ :"
echo "• FullRecognitionService retiré du manifest"
echo "• Backup créé: AndroidManifest.xml.backup"
echo "• WakeWordService, ModelDownloadService et MagicAccessibilityService conservés"

echo ""
echo "🔍 VÉRIFICATION :"
grep -n "FullRecognitionService" app/src/main/AndroidManifest.xml && echo "❌ Présent" || echo "✅ Absent"

echo ""
echo "🎯 TEST :"
echo "Le TTS de bienvenue devrait maintenant détecter la langue système correctement"
echo "Sans simulation de FullRecognitionService"
