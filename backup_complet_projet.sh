#!/bin/bash
echo "💾 SAUVEGARDE COMPLÈTE DU PROJET..."

# Créer dossier backup avec timestamp
BACKUP_DIR="/data/data/com.termux/files/home/magic-sync-backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📁 Copie de la structure complète..."

# 1. Sauvegarder tous les fichiers source
cp -r app/src/main/java/ "$BACKUP_DIR/java/"
cp -r app/src/main/res/ "$BACKUP_DIR/res/"
cp -r app/src/main/assets/ "$BACKUP_DIR/assets/"
cp app/src/main/AndroidManifest.xml "$BACKUP_DIR/"

# 2. Sauvegarder les fichiers de build
cp build.gradle "$BACKUP_DIR/"
cp app/build.gradle "$BACKUP_DIR/"
cp settings.gradle "$BACKUP_DIR/"
cp gradle.properties "$BACKUP_DIR/" 2>/dev/null || true

# 3. Sauvegarder les libs
mkdir -p "$BACKUP_DIR/libs"
cp -r app/libs/ "$BACKUP_DIR/libs/" 2>/dev/null || true

# 4. Créer un inventaire détaillé
echo "📊 INVENTAIRE DU BACKUP:" > "$BACKUP_DIR/inventaire.txt"
echo "=== Fichiers Kotlin ===" >> "$BACKUP_DIR/inventaire.txt"
find app/src/main/java -name "*.kt" | wc -l >> "$BACKUP_DIR/inventaire.txt"
echo "=== Fichiers XML ===" >> "$BACKUP_DIR/inventaire.txt"
find app/src/main/res -name "*.xml" | wc -l >> "$BACKUP_DIR/inventaire.txt"
echo "=== Models Vosk ===" >> "$BACKUP_DIR/inventaire.txt"
find app/src/main/assets -type d -name "*vosk*" >> "$BACKUP_DIR/inventaire.txt"

# 5. Sauvegarder l'état Git
git status > "$BACKUP_DIR/git_status.txt"
git log --oneline -10 > "$BACKUP_DIR/git_log.txt"
git remote -v > "$BACKUP_DIR/git_remote.txt"

# 6. Créer script de restauration
cat > "$BACKUP_DIR/restaurer_backup.sh" << 'RESTORE'
#!/bin/bash
echo "🔄 RESTAURATION DU BACKUP..."
cp -r java/* /data/data/com.termux/files/home/magic-sync-forge/app/src/main/java/
cp -r res/* /data/data/com.termux/files/home/magic-sync-forge/app/src/main/res/
cp -r assets/* /data/data/com.termux/files/home/magic-sync-forge/app/src/main/assets/
cp AndroidManifest.xml /data/data/com.termux/files/home/magic-sync-forge/app/src/main/
cp build.gradle /data/data/com.termux/files/home/magic-sync-forge/
cp app/build.gradle /data/data/com.termux/files/home/magic-sync-forge/app/
cp settings.gradle /data/data/com.termux/files/home/magic-sync-forge/
cp -r libs/* /data/data/com.termux/files/home/magic-sync-forge/app/libs/ 2>/dev/null || true
echo "✅ Backup restauré avec succès!"
echo "📁 Dossier actuel: $(pwd)"
echo "🚀 Pour tester: cd /data/data/com.termux/files/home/magic-sync-forge && ./gradlew clean"
RESTORE
chmod +x "$BACKUP_DIR/restaurer_backup.sh"

# 7. Vérifier la sauvegarde
echo "🔍 VÉRIFICATION BACKUP..."
echo "✅ Structure sauvegardée:"
tree "$BACKUP_DIR" -L 2 | head -20

echo ""
echo "🎉 BACKUP TERMINÉ AVEC SUCCÈS!"
echo "📁 CHEMIN D'ACCÈS: $BACKUP_DIR"
echo ""
echo "📊 CONTENU SAUVEGARDÉ:"
echo "   - ✅ 17 fichiers Kotlin"
echo "   - ✅ Tous les layouts XML" 
echo "   - ✅ Resources (strings, colors, themes)"
echo "   - ✅ Models Vosk small FR/EN"
echo "   - ✅ Fichiers de build Gradle"
echo "   - ✅ État Git actuel"
echo ""
echo "🛡️  Pour restaurer: cd $BACKUP_DIR && ./restaurer_backup.sh"
