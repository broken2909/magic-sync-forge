#!/bin/bash
echo "🔧 RESTAURATION BACKUP FONCTIONNEL"

cd /data/data/com.termux/files/home/magic-sync-forge/

# Restaurer le backup
cp app/src/main/java/com/magiccontrol/service/WakeWordService.kt.backup app/src/main/java/com/magiccontrol/service/WakeWordService.kt

# Vérification
echo "✅ BACKUP RESTAURÉ"
echo "📋 TTS dans le fichier restauré:"
grep -A 5 -B 5 "TTSManager.speak" app/src/main/java/com/magiccontrol/service/WakeWordService.kt

echo ""
echo "🎯 VERSION FONCTIONNELLE RESTAURÉE"
echo "📊 Le backup du 21:59 avait TTS fonctionnel"
echo "🚀 PUSH: git add . && git commit -m 'RESTORE: Version fonctionnelle TTS depuis backup' && git push"
