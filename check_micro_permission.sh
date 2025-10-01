#!/bin/bash
echo "🔍 VÉRIFICATION AUTORISATION MICROPHONE"

echo ""
echo "📋 ANDROIDMANIFEST.XML - PERMISSIONS :"
grep -n "RECORD_AUDIO\\|MICROPHONE\\|permission" app/src/main/AndroidManifest.xml

echo ""
echo "📋 SERVICES AUDIO :"
grep -n "WakeWordService\\|FullRecognitionService" app/src/main/AndroidManifest.xml

echo ""
echo "📋 FICHIERS UTILISANT LE MICRO :"
find app/src/main/java -name "*.kt" -exec grep -l "RECORD_AUDIO\\|AudioRecord\\|MediaRecorder\\|Microphone" {} \;

echo ""
echo "📋 ÉTAT DES SERVICES :"
echo "• WakeWordService: $(grep -q "WakeWordService" app/src/main/AndroidManifest.xml && echo "✅ DÉCLARÉ" || echo "❌ NON DÉCLARÉ")"
echo "• FullRecognitionService: $(grep -q "FullRecognitionService" app/src/main/AndroidManifest.xml && echo "✅ DÉCLARÉ" || echo "❌ NON DÉCLARÉ")"

echo ""
echo "💡 DIAGNOSTIC :"
echo "L'autorisation micro peut manquer car :"
echo "1. Aucun service vocal n'est ACTIVÉ dans MainActivity"
echo "2. Les services sont déclarés mais jamais démarrés"
echo "3. L'app ne demande plus la permission au démarrage"
