#!/bin/bash
echo "🔧 INTÉGRATION SÉCURISÉE DU TTS DE BIENVENUE"

# Création d'une sauvegarde
cp app/src/main/java/com/magiccontrol/MainActivity.kt app/src/main/java/com/magiccontrol/MainActivity.kt.backup

# Intégration de l'appel TTS dans MainActivity
cat > app/src/main/java/com/magiccontrol/MainActivity.kt << 'MAINACTIVITY'
package com.magiccontrol

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.magiccontrol.utils.FirstLaunchWelcome

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // Activation du message vocal de bienvenue au premier lancement
        FirstLaunchWelcome.playWelcomeIfFirstLaunch(this)
    }
}
MAINACTIVITY

echo ""
echo "✅ INTÉGRATION TERMINÉE :"
echo "• FirstLaunchWelcome.playWelcomeIfFirstLaunch(this) ajouté"
echo "• Backup créé: MainActivity.kt.backup"

echo ""
echo "📋 VÉRIFICATION :"
grep -n "FirstLaunchWelcome" app/src/main/java/com/magiccontrol/MainActivity.kt

echo ""
echo "🎯 TEST :"
echo "L'application peut maintenant être testée localement"
echo "Le message vocal se jouera uniquement au premier lancement"
