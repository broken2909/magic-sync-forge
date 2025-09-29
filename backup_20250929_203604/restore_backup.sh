#!/bin/bash
echo "🔄 RESTAURATION BACKUP..."
cp -r service/* ../../app/src/main/java/com/magiccontrol/service/
cp -r recognizer/* ../../app/src/main/java/com/magiccontrol/recognizer/
cp AndroidManifest.xml ../../app/src/main/
cp build.gradle ../../app/build.gradle
echo "✅ Backup restauré!"
echo "🔍 Vérification..."
find ../../app/src/main/java -name "*.kt" -exec md5sum {} \; > checksums_apres.txt
diff checksums_avant.txt checksums_apres.txt && echo "✅ Fichiers identiques" || echo "⚠️ Différences détectées"
