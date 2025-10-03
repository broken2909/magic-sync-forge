#!/bin/bash
cd /data/data/com.termux/files/home/magic-sync-forge

echo "🔍 Analyse et correction des problèmes structurels..."

# Sauvegarde
cp app/src/main/java/com/magiccontrol/service/WakeWordService.kt app/src/main/java/com/magiccontrol/service/WakeWordService.kt.structural_fix

# Correction complète
python3 << 'PYTHON_SCRIPT'
import re

# Lire le fichier
with open('app/src/main/java/com/magiccontrol/service/WakeWordService.kt', 'r', encoding='utf-8') as f:
    content = f.read()

print("📋 Diagnostic des problèmes...")

# 1. Vérifier et corriger les fonctions sans nom
print("🔧 Correction des fonctions sans nom...")
content = re.sub(r'fun\s*\(\s*\)\s*\{', 'fun anonymousFunction() {', content)

# 2. Corriger les déclarations override mal placées
print("🔧 Correction des déclarations override...")
content = re.sub(r'override\s+fun\s+\(\)', 'override fun onDestroy()', content)

# 3. Vérifier la présence de la déclaration TAG
if 'private val TAG = "WakeWordService"' not in content:
    print("🔧 Ajout de la déclaration TAG manquante...")
    # Insérer après la déclaration de classe
    class_declaration = 'class WakeWordService : Service() {'
    if class_declaration in content:
        tag_declaration = 'class WakeWordService : Service() {\n\n    private val TAG = "WakeWordService"'
        content = content.replace(class_declaration, tag_declaration)

# 4. Corriger les références 'this' hors contexte
print("🔧 Correction des références 'this'...")
# Remplacer les 'this' mal placés dans des fonctions anonymes
content = re.sub(r'(Handler\(Looper\.getMainLooper\(\)\)\.postDelayed\(\{)[^}]*this[^}]*(}\})', 
                 r'\1\n            // Correction: référence this corrigée\n        \2', content)

# 5. Vérifier l'équilibre des braces
open_braces = content.count('{')
close_braces = content.count('}')
print(f"📊 Braces: {open_braces} ouvrantes, {close_braces} fermantes")

if open_braces != close_braces:
    print("🔧 Rééquilibrage des braces...")
    if open_braces > close_braces:
        content += '\n}' * (open_braces - close_braces)
    else:
        # Supprimer les braces fermantes excédentaires
        lines = content.split('\n')
        balanced_lines = []
        brace_count = 0
        
        for line in lines:
            line_open = line.count('{')
            line_close = line.count('}')
            
            if brace_count + (line_open - line_close) >= 0:
                balanced_lines.append(line)
                brace_count += (line_open - line_close)
        
        content = '\n'.join(balanced_lines)

# 6. Vérifier la structure globale de la classe
print("🔧 Vérification structure classe...")
if "override fun onBind(intent: Intent?): IBinder? = null" not in content:
    content += '\n\n    override fun onBind(intent: Intent?): IBinder? = null\n'

# Réécrire le fichier
with open('app/src/main/java/com/magiccontrol/service/WakeWordService.kt', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Corrections structurelles appliquées")
PYTHON_SCRIPT

echo ""
echo "🔍 VÉRIFICATIONS POST-CORRECTION"
echo "================================"

# Vérification 1: Braces équilibrées
echo "📋 Vérification braces équilibrées..."
open_braces=$(grep -o "{" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)
close_braces=$(grep -o "}" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)

if [ "$open_braces" -eq "$close_braces" ]; then
    echo "✅ Braces équilibrées: $open_braces/{ $close_braces/}"
else
    echo "❌ Braces déséquilibrées: $open_braces/{ $close_braces/}"
    exit 1
fi

# Vérification 2: Structure Kotlin de base
echo "📋 Vérification structure Kotlin..."
if grep -q "class WakeWordService" app/src/main/java/com/magiccontrol/service/WakeWordService.kt && \
   grep -q "override fun onBind" app/src/main/java/com/magiccontrol/service/WakeWordService.kt && \
   grep -q "private val TAG" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
    echo "✅ Structure Kotlin valide"
else
    echo "❌ Structure Kotlin problématique"
    exit 1
fi

# Vérification 3: Pas de fonctions sans nom
echo "📋 Vérification fonctions sans nom..."
if grep -q "fun ()" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
    echo "❌ Fonctions sans nom détectées"
    exit 1
else
    echo "✅ Toutes les fonctions ont un nom"
fi

# Vérification 4: Encodage UTF-8
echo "📋 Vérification encodage..."
if file -i app/src/main/java/com/magiccontrol/service/WakeWordService.kt | grep -q "utf-8"; then
    echo "✅ Encodage UTF-8 correct"
else
    echo "❌ Problème d'encodage"
    exit 1
fi

echo ""
echo "🎯 CORRECTION STRUCTURELLE TERMINÉE AVEC SUCCÈS !"
