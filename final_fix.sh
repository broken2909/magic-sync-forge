#!/bin/bash
echo "🔧 SUPPRESSION TTS DUPLIQUÉ CASSÉ"

cd /data/data/com.termux/files/home/magic-sync-forge/

# Supprimer UNIQUEMENT le bloc TTS cassé (lignes 37-41)
sed -i '37,41d' app/src/main/java/com/magiccontrol/service/WakeWordService.kt

# Vérification
echo "✅ BLOC CASSÉ SUPPRIMÉ"
echo "📋 onStartCommand maintenant:"
sed -n '28,35p' app/src/main/java/com/magiccontrol/service/WakeWordService.kt

echo ""
echo "🎯 FICHIER CORRIGÉ - UN SEUL TTS FONCTIONNEL"
echo "🚀 PUSH: git add . && git commit -m 'FIX: Suppression TTS dupliqué cassé - Un seul TTS fonctionnel' && git push"
