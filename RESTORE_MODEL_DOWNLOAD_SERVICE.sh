#!/bin/bash

echo "🔧 RESTAURATION ModelDownloadService FONCTIONNEL"

# Sauvegarde
cp app/src/main/java/com/magiccontrol/service/ModelDownloadService.kt app/src/main/java/com/magiccontrol/service/ModelDownloadService.kt.backup_emergent

# Récupération version fonctionnelle depuis no-see-clean
cp /data/data/com.termux/files/home/no-see-clean/app/src/main/java/com/magiccontrol/service/ModelDownloadService.kt app/src/main/java/com/magiccontrol/service/ModelDownloadService.kt

echo "✅ ModelDownloadService restauré depuis no-see-clean"
echo "🔍 Vérification :"
grep -n "wasExtractionNeeded" app/src/main/java/com/magiccontrol/service/ModelDownloadService.kt | head -5
