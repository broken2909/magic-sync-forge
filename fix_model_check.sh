#!/bin/bash
echo "🔧 CORRECTION APPEL isModelAvailable - Paramètre manquant"

cd /data/data/com.termux/files/home/magic-sync-forge/

# ==================== VÉRIFICATIONS ====================
echo "=== 🔍 VÉRIFICATION ERREUR ==="
grep -n "isModelAvailable(context, currentLanguage)" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

# ==================== CORRECTION ====================
echo ""
echo "=== 🛠️ APPLICATION CORRECTION ==="

# Correction dans WakeWordDetector.kt
sed -i 's/ModelManager.isModelAvailable(context, currentLanguage)/ModelManager.isModelAvailable(context, currentLanguage, "small")/' app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

# Vérification correction
echo "=== ✅ VÉRIFICATION CORRECTION ==="
grep -n "isModelAvailable" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

echo ""
echo "🎯 CORRECTION APPLIQUÉE"
echo "📊 Résumé: Ajout paramètre modelType='small' dans isModelAvailable()"
echo "🚀 TEST: ./gradlew assembleDebug --console=plain"
