#!/bin/bash
echo "🔧 CORRECTION DÉLAI TTS - 3000L manquant"

cd /data/data/com.termux/files/home/magic-sync-forge/

# ==================== VÉRIFICATION PRÉALABLE ====================
echo "=== 🔍 VÉRIFICATION DÉLAI ACTUEL ==="
grep -A 5 -B 5 "postDelayed" app/src/main/java/com/magiccontrol/service/WakeWordService.kt

# ==================== CORRECTION PRÉCISE ====================
echo ""
echo "=== 🛠️ CORRECTION CIBLÉE ==="

# Correction UNIQUEMENT de la ligne du délai
sed -i 's/postDelayed({/, 3000L)/' app/src/main/java/com/magiccontrol/service/WakeWordService.kt

# ==================== VÉRIFICATIONS ====================
echo ""
echo "=== ✅ VÉRIFICATIONS ==="

# Vérifier délai corrigé
if grep -q "postDelayed.*3000L" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
    echo "✅ Délai 3000L rétabli"
else
    echo "❌ Délai toujours manquant"
    # Afficher la ligne problématique
    grep "postDelayed" app/src/main/java/com/magiccontrol/service/WakeWordService.kt
    exit 1
fi

# Vérifier syntaxe complète
echo "=== 📋 LIGNE CORRIGÉE ==="
grep -A 2 -B 2 "postDelayed" app/src/main/java/com/magiccontrol/service/WakeWordService.kt

# Vérifier build
echo "=== 🔨 TEST SYNTAXE ==="
if ./gradlew compileDebugKotlin --console=plain > /dev/null 2>&1; then
    echo "✅ Syntaxe Kotlin valide"
else
    echo "❌ Erreur de syntaxe"
    exit 1
fi

echo ""
echo "🎯 DÉLAI TTS CORRIGÉ"
echo "📊 Délai 3000L rétabli - Build OK"
echo "🚀 PUSH: git add . && git commit -m 'FIX: Correction délai TTS 3000L' && git push"
