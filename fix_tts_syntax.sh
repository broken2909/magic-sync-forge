#!/bin/bash
echo "🔧 CORRECTION SYNTAXE TTS - Délai cassé"

cd /data/data/com.termux/files/home/magic-sync-forge/

# ==================== CORRECTION EXACTE ====================
echo "=== 🛠️ CORRECTION LIGNES 36-39 ==="

# Créer correction précise
cat > temp_fix.txt << 'FIX'
        // ✅ TTS APRÈS 3 SECONDES - COMPLETEMENT RÉTABLI
        Handler(Looper.getMainLooper()).postDelayed({
            Log.d(TAG, "🔊 Lancement message vocal d'activation")
            TTSManager.speak(applicationContext, applicationContext.getString(R.string.activation_prompt))
        }, 3000L)
FIX

# Remplacer les lignes problématiques
sed -i '36,39d' app/src/main/java/com/magiccontrol/service/WakeWordService.kt
sed -i '35r temp_fix.txt' app/src/main/java/com/magiccontrol/service/WakeWordService.kt
rm temp_fix.txt

# ==================== VÉRIFICATIONS ====================
echo ""
echo "=== ✅ VÉRIFICATIONS ==="

# Vérifier correction
echo "=== 📋 LIGNES CORRIGÉES ==="
sed -n '35,40p' app/src/main/java/com/magiccontrol/service/WakeWordService.kt

# Vérifier délai
if grep -q "postDelayed.*3000L" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
    echo "✅ Délai 3000L corrigé"
else
    echo "❌ Délai toujours cassé"
    exit 1
fi

# Vérifier syntaxe
if grep -q "Handler(Looper.getMainLooper()).postDelayed({" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
    echo "✅ Syntaxe Handler corrigée"
else
    echo "❌ Syntaxe Handler cassée"
    exit 1
fi

# Vérifier braces
start_braces=$(grep -o "{" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)
end_braces=$(grep -o "}" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)
if [ "$start_braces" -eq "$end_braces" ]; then
    echo "✅ Braces équilibrées: $start_braces"
else
    echo "❌ Braces déséquilibrées: $start_braces { vs $end_braces }"
    exit 1
fi

echo ""
echo "🎯 SYNTAXE TTS CORRIGÉE"
echo "📊 Handler et délai 3000L rétablis"
echo "🚀 PUSH: git add . && git commit -m 'FIX: Correction syntaxe TTS - Handler et délai 3000L' && git push"
