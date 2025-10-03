#!/bin/bash
echo "🔍 DEBUG SERVICE ÉCOUTE - Points critiques"

cd /data/data/com.termux/files/home/magic-sync-forge/

echo "=== 📋 VÉRIFICATION MAINACTIVITY ==="
grep -A 10 -B 5 "WakeWordService" app/src/main/java/com/magiccontrol/MainActivity.kt

echo ""
echo "=== 📋 VÉRIFICATION ANDROIDMANIFEST ==="
grep -A 5 -B 5 "WakeWordService" app/src/main/AndroidManifest.xml

echo ""
echo "=== 📋 VÉRIFICATION DÉMARRAGE SERVICE ==="
grep -A 5 -B 5 "startService.*WakeWordService" app/src/main/java/com/magiccontrol/MainActivity.kt

echo ""
echo "=== 📋 VÉRIFICATION PERMISSIONS FOREGROUND ==="
grep -A 5 -B 5 "FOREGROUND_SERVICE" app/src/main/AndroidManifest.xml

echo ""
echo "=== 🎯 POINTS CRITIQUES À VÉRIFIER ==="
echo "1. MainActivity démarre-t-il WakeWordService?"
echo "2. Le service a-t-il la permission FOREGROUND_SERVICE?"
echo "3. La notification foreground est-elle créée?"
echo "4. Le service survive-t-il au redémarrage de l'app?"
