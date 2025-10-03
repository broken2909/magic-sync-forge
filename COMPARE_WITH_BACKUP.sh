#!/bin/bash

echo "🔍 COMPARAISON AVEC SAUVEGARDE PRE-EMERGENT"

echo "=== Différence MainActivity vs Backup ==="
diff -u app/src/main/java/com/magiccontrol/MainActivity.kt.backup app/src/main/java/com/magiccontrol/MainActivity.kt | head -30
