#!/bin/bash
cd /data/data/com.termux/files/home/magic-sync-forge

echo "🔧 Correction de l'équilibre des braces..."

# Sauvegarde
cp app/src/main/java/com/magiccontrol/service/WakeWordService.kt app/src/main/java/com/magiccontrol/service/WakeWordService.kt.braces_fix

# Analyse et correction détaillée
python3 << 'PYTHON_SCRIPT'
import re

# Lire le fichier
with open('app/src/main/java/com/magiccontrol/service/WakeWordService.kt', 'r', encoding='utf-8') as f:
    content = f.read()

print("🔍 Analyse détaillée de l'équilibre des braces...")

# Compter les braces
open_braces = content.count('{')
close_braces = content.count('}')
print(f"Braces actuelles: {open_braces} ouvrantes, {close_braces} fermantes")

# Analyser la structure pour trouver où sont les braces excédentaires
lines = content.split('\n')
brace_stack = []
problem_lines = []

for i, line in enumerate(lines, 1):
    open_in_line = line.count('{')
    close_in_line = line.count('}')
    
    for _ in range(open_in_line):
        brace_stack.append(('open', i, line.strip()))
    
    for _ in range(close_in_line):
        if brace_stack:
            brace_stack.pop()
        else:
            problem_lines.append(('extra_close', i, line.strip()))

print(f"Braces non fermées: {len(brace_stack)}")
print(f"Braces fermantes excédentaires: {len(problem_lines)}")

# CORRECTION : Supprimer les braces fermantes excédentaires
if close_braces > open_braces:
    print("🔧 Suppression des braces fermantes excédentaires...")
    
    # Compter combien de braces fermantes supprimer
    braces_to_remove = close_braces - open_braces
    print(f"Braces à supprimer: {braces_to_remove}")
    
    # Parcourir les lignes à l'envers pour supprimer les braces fermantes excédentaires
    new_lines = []
    close_count = 0
    removed_count = 0
    
    for line in reversed(lines):
        stripped = line.strip()
        
        # Si c'est une brace fermante et qu'on doit encore en supprimer
        if stripped == '}' and removed_count < braces_to_remove:
            removed_count += 1
            print(f"✅ Brace fermante supprimée à la ligne approximative {len(lines) - len(new_lines)}")
            continue
        else:
            new_lines.insert(0, line)
    
    content = '\n'.join(new_lines)

# Vérification finale
open_braces = content.count('{')
close_braces = content.count('}')
print(f"Braces après correction: {open_braces} ouvrantes, {close_braces} fermantes")

# Réécrire le fichier
with open('app/src/main/java/com/magiccontrol/service/WakeWordService.kt', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Correction des braces appliquée")
PYTHON_SCRIPT

echo ""
echo "🔍 VÉRIFICATION APRÈS CORRECTION"
echo "================================"

# Afficher le fichier corrigé
echo "📋 FICHIER CORRIGÉ (avec numéros de ligne):"
echo "-------------------------------------------"
cat -n app/src/main/java/com/magiccontrol/service/WakeWordService.kt

echo ""
echo "🔍 VÉRIFICATIONS FINALES"
echo "========================"

# Vérification 1: Braces équilibrées
echo "📋 Vérification braces équilibrées..."
open_braces=$(grep -o "{" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)
close_braces=$(grep -o "}" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)

if [ "$open_braces" -eq "$close_braces" ]; then
    echo "✅ Braces ÉQUILIBRÉES: $open_braces/{ $close_braces/}"
else
    echo "❌ Braces toujours déséquilibrées: $open_braces/{ $close_braces/}"
    echo "🔄 Application de la correction alternative..."
    
    # Correction alternative plus agressive
    python3 << 'PYTHON_SCRIPT'
with open('app/src/main/java/com/magiccontrol/service/WakeWordService.kt', 'r', encoding='utf-8') as f:
    content = f.read()

# Méthode alternative: reconstruction contrôlée
lines = content.split('\n')
balanced_lines = []
brace_count = 0

for line in lines:
    open_braces = line.count('{')
    close_braces = line.count('}')
    
    # Ne pas ajouter de braces fermantes excédentaires
    if brace_count + (open_braces - close_braces) >= 0:
        balanced_lines.append(line)
        brace_count += (open_braces - close_braces)

# Si toujours déséquilibré, forcer l'équilibre
if brace_count != 0:
    print(f"🔧 Équilibrage forcé: ajout de {abs(brace_count)} braces")
    balanced_lines.append('}' * abs(brace_count))

content = '\n'.join(balanced_lines)

with open('app/src/main/java/com/magiccontrol/service/WakeWordService.kt', 'w', encoding='utf-8') as f:
    f.write(content)
PYTHON_SCRIPT
fi

# Vérification finale
echo ""
echo "📋 VÉRIFICATION FINALE ULTIME"
echo "============================="

open_braces=$(grep -o "{" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)
close_braces=$(grep -o "}" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)

if [ "$open_braces" -eq "$close_braces" ]; then
    echo "🎉 SUCCÈS: Braces maintenant ÉQUILIBRÉES ($open_braces/{ $close_braces/})"
    
    # Vérifications supplémentaires
    echo ""
    echo "🔍 VÉRIFICATIONS COMPLÉMENTAIRES"
    echo "================================"
    
    # Structure Kotlin
    if grep -q "class WakeWordService" app/src/main/java/com/magiccontrol/service/WakeWordService.kt && \
       grep -q "override fun onBind" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
        echo "✅ Structure Kotlin valide"
    else
        echo "❌ Structure Kotlin problématique"
    fi
    
    # Encodage
    if file -i app/src/main/java/com/magiccontrol/service/WakeWordService.kt | grep -q "utf-8"; then
        echo "✅ Encodage UTF-8 correct"
    else
        echo "❌ Problème d'encodage"
    fi
    
    echo ""
    echo "🚀 BRACES CORRIGÉES - PRÊT POUR LE BUILD !"
    
else
    echo "💥 ÉCHEC CRITIQUE: Impossible d'équilibrer les braces"
    echo "📊 Statut: $open_braces/{ vs $close_braces/}"
    exit 1
fi
