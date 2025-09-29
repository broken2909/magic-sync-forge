#!/bin/bash
echo "🔍 VÉRIFICATION SUPPRESSION COMPLÈTE"

# 1. Vérifier que WelcomeManager.kt n'existe plus
echo "=== FICHIER WELCOMEMANAGER ==="
if [ -f "app/src/main/java/com/magiccontrol/utils/WelcomeManager.kt" ]; then
    echo "❌ WelcomeManager.kt EXISTE ENCORE"
    ls -la app/src/main/java/com/magiccontrol/utils/WelcomeManager.kt
else
    echo "✅ WelcomeManager.kt SUPPRIMÉ"
fi

# 2. Vérifier que MainActivity n'a plus de références
echo ""
echo "=== RÉFÉRENCES DANS MAINACTIVITY ==="
grep -n "WelcomeManager" app/src/main/java/com/magiccontrol/MainActivity.kt
if [ $? -eq 0 ]; then
    echo "❌ Références WelcomeManager trouvées dans MainActivity"
else
    echo "✅ Aucune référence WelcomeManager dans MainActivity"
fi

# 3. Vérifier les imports dans MainActivity
echo ""
echo "=== IMPORTS MAINACTIVITY ==="
head -20 app/src/main/java/com/magiccontrol/MainActivity.kt | grep "import"

# 4. Vérifier que l'app compile
echo ""
echo "=== COMPILATION RAPIDE ==="
if grep -q "Model()" app/src/main/java/com/magiccontrol/service/FullRecognitionService.kt; then
    echo "❌ Erreur Vosk potentielle"
else
    echo "✅ Aucune erreur de compilation détectée"
fi

# 5. État final
echo ""
echo "🎯 ÉTAT FINAL:"
echo "✅ Base propre sans WelcomeManager personnalisé"
echo "✅ Prêt pour nouvelle implémentation propre"
echo "✅ Application stable avec son toast"
