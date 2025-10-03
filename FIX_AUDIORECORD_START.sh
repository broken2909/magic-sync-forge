#!/bin/bash

echo "🔧 CORRECTION - AJOUT startRecording()"

PROJECT_DIR="/data/data/com.termux/files/home/magic-sync-forge"
cd "$PROJECT_DIR"

FILE="app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt"

# Sauvegarde
cp "$FILE" "$FILE.backup_audio_fix"

# Ajouter startRecording() après l'initialisation réussie
sed -i '/if (audioRecord?.state != AudioRecord.STATE_INITIALIZED) {/,/audioRecord = null/a\
            }\
            \
            // DÉMARRAGE CAPTURE AUDIO\
            try {\
                audioRecord?.startRecording()\
                Log.d(TAG, "✅ Capture audio démarrée")\
            } catch (e: Exception) {\
                Log.e(TAG, "❌ Erreur démarrage capture audio", e)\
                audioRecord?.release()\
                audioRecord = null\
                return false\
            }' "$FILE"

echo "✅ startRecording() AJOUTÉ"
echo ""
echo "🔍 VÉRIFICATION :"
grep -n -A 5 "startRecording()" "$FILE"

echo ""
echo "🎯 CORRECTION EFFECTUÉE :"
echo "- AudioRecord.startRecording() ajouté après initialisation"
echo "- Gestion d'erreurs pour startRecording()"
echo "- Log de confirmation"
