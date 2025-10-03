#!/bin/bash

echo "🔍 VÉRIFICATION COMPLÈTE DU FICHIER RESTAURÉ"

PROJECT_DIR="/data/data/com.termux/files/home/magic-sync-forge"
cd "$PROJECT_DIR"

FILE="app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt"

echo "=== 📄 CONTENU COMPLET DU FICHIER ==="
cat "$FILE"

echo ""
echo "=== 🔍 RECHERCHE startRecording() ==="
if grep -q "startRecording()" "$FILE"; then
    echo "❌ startRecording() EST DÉJÀ PRÉSENT"
    grep -n "startRecording()" "$FILE"
else
    echo "✅ startRecording() EST ABSENT - À AJOUTER"
fi

echo ""
echo "=== 🔍 RECHERCHE BOUCLE AUDIO ==="
grep -n -A 10 "while (isListening)" "$FILE" | head -20
