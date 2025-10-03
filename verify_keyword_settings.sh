#!/bin/bash
echo "🔍 VÉRIFICATION MOT CLÉ & ACTIVATION COMMANDE VOCALE"

cd /data/data/com.termux/files/home/magic-sync-forge/

echo "=== 🎯 CONFIGURATION MOT CLÉ ==="
echo "1. Mot clé par défaut:"
grep -A 2 -B 2 "activation_keyword.*magic" app/src/main/java/com/magiccontrol/utils/PreferencesManager.kt

echo ""
echo "2. Dans WakeWordDetector - Vérification mot clé:"
grep -A 5 -B 5 "getActivationKeyword" app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt

echo ""
echo "=== 🔧 ÉTAT ACTIVATION ==="
echo "3. Vérification si commande vocale activée:"
grep -A 5 -B 5 "isVoiceFeedbackEnabled\\|voice_feedback" app/src/main/java/com/magiccontrol/utils/PreferencesManager.kt

echo ""
echo "=== 📱 DANS L'APPLICATION ==="
echo "4. Préférences par défaut (strings.xml):"
grep -A 2 -B 2 "voice_feedback.*true" app/src/main/res/values/strings.xml

echo ""
echo "=== 🎯 DIAGNOSTIC RAPIDE ==="
echo "À vérifier dans l'app:"
echo "✅ Paramètres → 'Magic' est-il le mot d'activation?"
echo "✅ Paramètres → 'Feedback vocal' est-il activé?"
echo "✅ Le service tourne-t-il? (notification)"
echo "✅ Les logs montrent-ils 'Voix détectée'?"
