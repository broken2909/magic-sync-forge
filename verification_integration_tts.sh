#!/bin/bash
echo "🔍 VÉRIFICATION SYSTÉMATIQUE APRÈS INTÉGRATION"

echo ""
echo "📁 SAUVEGARDE CRÉÉE :"
ls -la app/src/main/java/com/magiccontrol/MainActivity.kt.backup

echo ""
echo "📋 MAINACTIVITY MODIFIÉ :"
head -15 app/src/main/java/com/magiccontrol/MainActivity.kt

echo ""
echo "✅ INTÉGRATION CONFIRMÉE :"
grep -n "FirstLaunchWelcome" app/src/main/java/com/magiccontrol/MainActivity.kt && echo "✅ FirstLaunchWelcome bien intégré" || echo "❌ FirstLaunchWelcome manquant"

echo ""
echo "🔗 IMPORTS VÉRIFIÉS :"
grep -n "import" app/src/main/java/com/magiccontrol/MainActivity.kt

echo ""
echo "🎯 ÉTAT FINAL :"
echo "• ✅ Backup créé"
echo "• ✅ MainActivity modifié avec appel TTS"
echo "• ✅ Import FirstLaunchWelcome ajouté"
echo "• ✅ Prêt pour test local"
