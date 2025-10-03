#!/bin/bash

echo "🔍 VÉRIFICATION ÉTAT MODÈLES"

echo "=== Logs extraction dans ModelDownloadService ==="
grep -n "Modeles deja extraits:\|Extraction necessaire\|Resultat extraction:" app/src/main/java/com/magiccontrol/service/ModelDownloadService.kt

echo ""
echo "=== Méthode isModelExtracted ==="
grep -n -A10 "isModelExtracted" app/src/main/java/com/magiccontrol/service/ModelDownloadService.kt
