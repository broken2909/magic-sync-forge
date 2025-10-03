#!/bin/bash

echo "🔍 ANALYSE DIFFÉRENCES MainActivity"

echo "=== Différence complète ==="
diff -u /data/data/com.termux/files/home/no-see-clean/app/src/main/java/com/magiccontrol/MainActivity.kt app/src/main/java/com/magiccontrol/MainActivity.kt | head -50
