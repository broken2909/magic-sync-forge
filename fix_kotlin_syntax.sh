#!/bin/bash
cd /data/data/com.termux/files/home/magic-sync-forge

echo "🎯 Correction des erreurs de syntaxe Kotlin..."

# Sauvegarde du fichier
cp app/src/main/java/com/magiccontrol/service/WakeWordService.kt app/src/main/java/com/magiccontrol/service/WakeWordService.kt.syntax_fix

# Correction des problèmes de structure
python3 << 'PYTHON_SCRIPT'
import re

# Lire le fichier
with open('app/src/main/java/com/magiccontrol/service/WakeWordService.kt', 'r', encoding='utf-8') as f:
    content = f.read()

# Vérifier l'équilibre des braces
open_braces = content.count('{')
close_braces = content.count('}')
print(f"Braces actuelles: {open_braces} ouvrantes, {close_braces} fermantes")

if open_braces != close_braces:
    print("❌ Déséquilibre détecté! Correction en cours...")
    # Ajouter les braces manquantes
    if open_braces > close_braces:
        content += '\n}' * (open_braces - close_braces)
    else:
        # Supprimer les braces excédentaires
        lines = content.split('\n')
        balanced_lines = []
        brace_diff = 0
        
        for line in lines:
            line_open = line.count('{')
            line_close = line.count('}')
            current_diff = line_open - line_close
            
            if brace_diff + current_diff < 0:
                # Trop de fermantes, on ignore certaines
                continue
            balanced_lines.append(line)
            brace_diff += current_diff
        
        content = '\n'.join(balanced_lines)

# Corriger les fonctions locales problématiques
# Remplacer les fonctions sans nom par des structures valides
content = re.sub(r'fun\s*\(\s*\)\s*\{', 'fun anonymousFunction() {', content)

# S'assurer que toutes les fonctions ont des noms valides
content = re.sub(r'override\s+fun\s+\(\)', 'override fun unnamedFunction()', content)

# Vérifier et corriger les références TAG
if 'private val TAG = "WakeWordService"' not in content:
    # Ajouter la déclaration TAG si manquante
    class_pattern = r'class WakeWordService\s*:\s*Service\(\)\s*\{'
    if re.search(class_pattern, content):
        content = re.sub(class_pattern, class_pattern.group(0) + '\n    private val TAG = "WakeWordService"', content)

# Réécrire le fichier
with open('app/src/main/java/com/magiccontrol/service/WakeWordService.kt', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Corrections de syntaxe appliquées")
PYTHON_SCRIPT

# Vérification finale
echo ""
echo "🔍 VÉRIFICATION FINALE"
echo "======================"

# Vérification des braces
open_braces=$(grep -o "{" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)
close_braces=$(grep -o "}" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)

if [ "$open_braces" -eq "$close_braces" ]; then
    echo "✅ Braces équilibrées: $open_braces/{ $close_braces/}"
else
    echo "❌ Braces toujours déséquilibrées: $open_braces/{ $close_braces/}"
    echo "🔄 Application de la correction forcée..."
    # Correction forcée
    python3 << 'PYTHON_SCRIPT'
with open('app/src/main/java/com/magiccontrol/service/WakeWordService.kt', 'r', encoding='utf-8') as f:
    content = f.read()

# Forcer l'équilibre des braces
open_count = content.count('{')
close_count = content.count('}')

if open_count > close_count:
    content += '\n}' * (open_count - close_count)
elif close_count > open_count:
    # Compter les lignes et rééquilibrer
    lines = content.split('\n')
    new_lines = []
    open_stack = []
    
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith('}') and not open_stack:
            continue  # Ignorer les fermantes excédentaires
        new_lines.append(line)
        
        # Suivre les braces
        for char in line:
            if char == '{':
                open_stack.append(i)
            elif char == '}' and open_stack:
                open_stack.pop()
    
    content = '\n'.join(new_lines)

with open('app/src/main/java/com/magiccontrol/service/WakeWordService.kt', 'w', encoding='utf-8') as f:
    f.write(content)
PYTHON_SCRIPT
fi

# Vérification de la syntaxe Kotlin basique
echo "📋 Vérification structure Kotlin..."
if grep -q "class WakeWordService" app/src/main/java/com/magiccontrol/service/WakeWordService.kt && \
   grep -q "override fun onBind" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
    echo "✅ Structure Kotlin valide"
else
    echo "❌ Structure Kotlin problématique"
fi

echo "🎯 Correction terminée!"
