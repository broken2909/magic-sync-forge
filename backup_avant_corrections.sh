#!/bin/bash
echo "💾 CREATION BACKUP COMPLET..."

# Créer dossier backup avec timestamp
BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Copier tous les fichiers critiques
echo "📁 Sauvegarde des fichiers..."
cp -r app/src/main/java/com/magiccontrol/service/ "$BACKUP_DIR/service/"
cp -r app/src/main/java/com/magiccontrol/recognizer/ "$BACKUP_DIR/recognizer/"
cp app/src/main/AndroidManifest.xml "$BACKUP_DIR/"
cp app/build.gradle "$BACKUP_DIR/"

# Créer un fichier de référence avec checksums
echo "🔍 Génération checksums..."
find app/src/main/java -name "*.kt" -exec md5sum {} \; > "$BACKUP_DIR/checksums_avant.txt"

# Sauvegarder l'état git actuel
echo "📦 Sauvegarde état Git..."
git status > "$BACKUP_DIR/git_status.txt"
git log --oneline -5 > "$BACKUP_DIR/git_log.txt"

# Créer script de restauration
cat > "$BACKUP_DIR/restore_backup.sh" << 'RESTORE'
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
RESTORE
chmod +x "$BACKUP_DIR/restore_backup.sh"

echo "✅ BACKUP COMPLÈTE TERMINÉE!"
echo "📁 Dossier: $BACKUP_DIR"
echo "📊 Contenu:"
ls -la "$BACKUP_DIR"
echo ""
echo "🛡️  Pour restaurer: cd $BACKUP_DIR && ./restore_backup.sh"
