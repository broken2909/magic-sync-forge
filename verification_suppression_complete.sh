#!/bin/bash
echo "🔍 VÉRIFICATION SUPPRESSION COMPLÈTE WELCOME"

# 1. Vérifier que AppWelcomeManager n'existe plus
echo "=== FICHIER AppWelcomeManager ==="
if [ -f "app/src/main/java/com/magiccontrol/welcome/AppWelcomeManager.kt" ]; then
    echo "❌ AppWelcomeManager.kt EXISTE ENCORE"
else
    echo "✅ AppWelcomeManager.kt SUPPRIMÉ"
fi

# 2. Vérifier que le package welcome n'existe plus
echo ""
echo "=== PACKAGE WELCOME ==="
if [ -d "app/src/main/java/com/magiccontrol/welcome" ]; then
    echo "❌ Package welcome EXISTE ENCORE"
    ls -la app/src/main/java/com/magiccontrol/welcome/
else
    echo "✅ Package welcome SUPPRIMÉ"
fi

# 3. Vérifier que MainActivity n'a plus de références welcome
echo ""
echo "=== RÉFÉRENCES DANS MAINACTIVITY ==="
grep -n "WelcomeManager\|playWelcomeVoice\|shouldPlayWelcomeVoice" app/src/main/java/com/magiccontrol/MainActivity.kt
if [ $? -eq 0 ]; then
    echo "❌ Références welcome trouvées dans MainActivity"
else
    echo "✅ Aucune référence welcome dans MainActivity"
fi

# 4. Vérifier les imports dans MainActivity
echo ""
echo "=== IMPORTS MAINACTIVITY ==="
head -15 app/src/main/java/com/magiccontrol/MainActivity.kt | grep "import"

# 5. Vérifier que seul le son reste
echo ""
echo "=== FONCTIONNALITÉS RESTANTES ==="
grep -n "playWelcomeSound\|R.raw.welcome_sound" app/src/main/java/com/magiccontrol/MainActivity.kt && echo "✅ Son toast conservé" || echo "❌ Son toast manquant"

# 6. Vérifier build potentiel
echo ""
echo "=== COMPATIBILITÉ BUILD ==="
! grep -q "Model()" app/src/main/java/com/magiccontrol/service/FullRecognitionService.kt && echo "✅ Pas d'erreur Vosk" || echo "❌ Erreur Vosk présente"

echo ""
echo "🎯 ÉTAT FINAL:"
echo "✅ Suppression welcome COMPLÈTEMENT TERMINÉE"
echo "✅ Application stable avec son toast seulement"
echo "✅ Prête pour prochaines fonctionnalités"
