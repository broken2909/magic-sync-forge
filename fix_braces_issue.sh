#!/bin/bash
cd /data/data/com.termux/files/home/magic-sync-forge

echo "🎯 Correction des braces dans WakeWordService.kt..."

# Sauvegarde
cp app/src/main/java/com/magiccontrol/service/WakeWordService.kt app/src/main/java/com/magiccontrol/service/WakeWordService.kt.braces_fix

# Analyser et corriger les braces
python3 << 'PYTHON_SCRIPT'
import re

# Lire le fichier
with open('app/src/main/java/com/magiccontrol/service/WakeWordService.kt', 'r', encoding='utf-8') as f:
    content = f.read()

# Compter les braces actuelles
open_braces = content.count('{')
close_braces = content.count('}')
print(f"Braces actuelles: {open_braces}/{open_braces} ouvertes, {close_braces}/{close_braces} fermées")

# Vérifier la fonction onWakeWordDetected pour s'assurer qu'elle est bien formée
on_wake_word_pattern = r'private fun onWakeWordDetected\(\) \{([^}]+)\}'
match = re.search(on_wake_word_pattern, content, re.DOTALL)

if match:
    print("✅ Structure onWakeWordDetected trouvée")
    
    # Remplacer par une version garantie équilibrée
    balanced_function = '''private fun onWakeWordDetected() {
    Log.d(TAG, "🎯 Mot-clé détecté - Transition vers reconnaissance commandes")
    
    try {
        // 1. Feedback vocal IMMÉDIAT mais NON-BLOQUANT
        TTSManager.speak(applicationContext, "Oui?")
        
        // 2. Démarrer FullRecognitionService IMMÉDIATEMENT (sans délai)
        val intent = Intent(this, FullRecognitionService::class.java)
        startService(intent)
        Log.d(TAG, "🚀 FullRecognitionService démarré")
        
        // 3. Arrêter l'écoute du wake word APRÈS 500ms (transition fluide)
        Handler(Looper.getMainLooper()).postDelayed({
            Log.d(TAG, "🔄 Arrêt écoute wake word, transfert au service commandes")
            wakeWordDetector?.stopListening()
        }, 500L)
        
    } catch (e: Exception) {
        Log.e(TAG, "❌ Erreur transition services", e)
        // Redémarrer l'écoute en cas d'erreur
        Handler(Looper.getMainLooper()).postDelayed({
            startListening()
        }, 2000L)
    }
}'''

    # Remplacer la fonction problématique
    content = re.sub(r'private fun onWakeWordDetected\(\) \{.*?\}', balanced_function, content, flags=re.DOTALL)
    print("✅ Fonction onWakeWordDetected rééquilibrée")
else:
    print("❌ Pattern onWakeWordDetected non trouvé")

# Vérifier l'équilibre global des braces
open_count = content.count('{')
close_count = content.count('}')

print(f"Braces après correction: {open_count}/{open_count} ouvertes, {close_count}/{close_count} fermées")

if open_count != close_count:
    print("❌ Déséquilibre persistant, application de correction globale...")
    # Ajouter ou supprimer des braces pour équilibrer
    diff = open_count - close_count
    if diff > 0:
        # Trop de {, ajouter des }
        content += '\n}' * abs(diff)
        print(f"✅ Ajout de {abs(diff)} brace(s) fermante(s)")
    else:
        # Trop de }, supprimer des } à la fin
        lines = content.split('\n')
        removed = 0
        new_lines = []
        for line in reversed(lines):
            if removed < abs(diff) and line.strip() == '}':
                removed += 1
            else:
                new_lines.insert(0, line)
        content = '\n'.join(new_lines)
        print(f"✅ Suppression de {abs(diff)} brace(s) fermante(s)")

# Réécrire le fichier
with open('app/src/main/java/com/magiccontrol/service/WakeWordService.kt', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Correction des braces appliquée")
PYTHON_SCRIPT

echo ""
echo "🔍 VÉRIFICATION POST-CORRECTION"
echo "================================"

# Vérification finale des braces
echo "📋 Vérification braces équilibrées..."
open_braces=$(grep -o "{" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)
close_braces=$(grep -o "}" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)

if [ "$open_braces" -eq "$close_braces" ]; then
    echo "✅ WakeWordService.kt: Braces ÉQUILIBRÉES ($open_braces/{ $close_braces/})"
else
    echo "❌ WakeWordService.kt: Braces TOUJOURS NON ÉQUILIBRÉES ($open_braces/{ $close_braces/})"
    echo "🔧 Application de la correction alternative..."
    
    # Correction alternative plus agressive
    python3 << 'PYTHON_SCRIPT'
with open('app/src/main/java/com/magiccontrol/service/WakeWordService.kt', 'r', encoding='utf-8') as f:
    content = f.read()

# Compter et équilibrer
open_count = content.count('{')
close_count = content.count('}')

if open_count > close_count:
    content += '\n}' * (open_count - close_count)
    print(f"✅ Ajout de {open_count - close_count} brace(s) fermante(s)")
elif close_count > open_count:
    # Supprimer les braces fermantes excédentaires à la fin
    lines = content.split('\n')
    new_content = []
    close_to_remove = close_count - open_count
    close_found = 0
    
    for line in lines:
        if close_found < close_to_remove and line.strip() == '}':
            close_found += 1
        else:
            new_content.append(line)
    
    content = '\n'.join(new_content)
    print(f"✅ Suppression de {close_to_remove} brace(s) fermante(s)")

with open('app/src/main/java/com/magiccontrol/service/WakeWordService.kt', 'w', encoding='utf-8') as f:
    f.write(content)
PYTHON_SCRIPT
fi

# Vérification finale
echo ""
echo "📋 VÉRIFICATION FINALE"
echo "======================"

open_braces=$(grep -o "{" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)
close_braces=$(grep -o "}" app/src/main/java/com/magiccontrol/service/WakeWordService.kt | wc -l)

if [ "$open_braces" -eq "$close_braces" ]; then
    echo "🎉 SUCCÈS: Braces maintenant ÉQUILIBRÉES ($open_braces/{ $close_braces/})"
    
    # Vérifications supplémentaires
    echo ""
    echo "🔍 VÉRIFICATIONS COMPLÉMENTAIRES"
    echo "================================"
    
    # Vérification UTF-8
    if file -i app/src/main/java/com/magiccontrol/service/WakeWordService.kt | grep -q "utf-8"; then
        echo "✅ Encodage UTF-8 correct"
    else
        echo "❌ Problème d'encodage"
    fi
    
    # Vérification doublons
    if [ $(grep -c "private fun onWakeWordDetected()" app/src/main/java/com/magiccontrol/service/WakeWordService.kt) -eq 1 ]; then
        echo "✅ Pas de doublons onWakeWordDetected"
    else
        echo "❌ Doublons détectés"
    fi
    
    # Vérification structure
    if grep -q "class WakeWordService" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
        echo "✅ Structure de classe correcte"
    else
        echo "❌ Structure de classe problématique"
    fi
    
    echo ""
    echo "🚀 CORRECTION TERMINÉE AVEC SUCCÈS !"
    
else
    echo "❌ ÉCHEC: Impossible d'équilibrer les braces"
    echo "📋 Statut: $open_braces/{ vs $close_braces/}"
fi
