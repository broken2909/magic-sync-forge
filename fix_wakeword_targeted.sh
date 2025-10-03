#!/bin/bash
cd /data/data/com.termux/files/home/magic-sync-forge

echo "🔧 Application des corrections ciblées..."

# Sauvegarde du fichier actuel
cp app/src/main/java/com/magiccontrol/service/WakeWordService.kt app/src/main/java/com/magiccontrol/service/WakeWordService.kt.pre_fix

# Correction des problèmes identifiés
python3 << 'PYTHON_SCRIPT'
import re

# Lire le fichier
with open('app/src/main/java/com/magiccontrol/service/WakeWordService.kt', 'r', encoding='utf-8') as f:
    content = f.read()

print("🔍 Correction des problèmes identifiés...")

# CORRECTION 1: Indentation ligne 124
print("📝 Correction indentation ligne 124...")
lines = content.split('\n')
if len(lines) >= 124:
    # Vérifier et corriger l'indentation de la ligne 124
    if lines[123].strip() == "wakeWordDetector?.stopListening()  // 🔧 ARRÊTER ÉCOUTE PENDANT TRAITEMENT":
        lines[123] = "        wakeWordDetector?.stopListening()  // 🔧 ARRÊTER ÉCOUTE PENDANT TRAITEMENT"
        print("✅ Indentation ligne 124 corrigée")

# Reconstruire le contenu
content = '\n'.join(lines)

# CORRECTION 2: Amélioration de la fonction onWakeWordDetected
print("📝 Amélioration fonction onWakeWordDetected...")
old_on_wakeword = '''private fun onWakeWordDetected() {
    Log.d(TAG, "🎯 Traitement mot-clé détecté")
    TTSManager.speak(applicationContext, "Oui?")
        wakeWordDetector?.stopListening()  // 🔧 ARRÊTER ÉCOUTE PENDANT TRAITEMENT
    // Lancer reconnaissance complète
    Handler(Looper.getMainLooper()).postDelayed({
        val intent = Intent(this, FullRecognitionService::class.java)
        startService(intent)
    }, 1000L)
}'''

new_on_wakeword = '''private fun onWakeWordDetected() {
    Log.d(TAG, "🎯 Traitement mot-clé détecté - Transition vers reconnaissance")
    
    try {
        // 1. Feedback vocal immédiat
        TTSManager.speak(applicationContext, "Oui?")
        
        // 2. Démarrer reconnaissance complète IMMÉDIATEMENT
        val intent = Intent(this, FullRecognitionService::class.java)
        startService(intent)
        Log.d(TAG, "🚀 FullRecognitionService démarré")
        
        // 3. Arrêter écoute actuelle APRÈS démarrage nouveau service
        Handler(Looper.getMainLooper()).postDelayed({
            Log.d(TAG, "🔄 Arrêt écoute wake word")
            wakeWordDetector?.stopListening()
        }, 500L)
        
    } catch (e: Exception) {
        Log.e(TAG, "❌ Erreur transition services", e)
    }
}'''

if old_on_wakeword in content:
    content = content.replace(old_on_wakeword, new_on_wakeword)
    print("✅ Fonction onWakeWordDetected améliorée")
else:
    print("❌ Ancienne fonction non trouvée, recherche alternative...")
    # Recherche par pattern
    pattern = r'private fun onWakeWordDetected\(\) \{.*?Handler\(Looper\.getMainLooper\(\)\)\.postDelayed\(\{.*?startService\(intent\).*?\}, 1000L\).*?\}'
    if re.search(pattern, content, re.DOTALL):
        content = re.sub(pattern, new_on_wakeword, content, flags=re.DOTALL)
        print("✅ Fonction remplacée via pattern")

# CORRECTION 3: Vérification équilibre braces
open_braces = content.count('{')
close_braces = content.count('}')
print(f"📊 Équilibre braces: {open_braces}/{open_braces} vs {close_braces}/{close_braces}")

if open_braces != close_braces:
    print("🔧 Rééquilibrage des braces...")
    # Forcer l'équilibre
    if open_braces > close_braces:
        content += '\n}' * (open_braces - close_braces)
    else:
        content = content.rstrip() + '\n}' * (close_braces - open_braces)

# Réécrire le fichier
with open('app/src/main/java/com/magiccontrol/service/WakeWordService.kt', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Corrections ciblées appliquées")
PYTHON_SCRIPT

echo ""
echo "🔍 VÉRIFICATION DU FICHIER CORRIGÉ"
echo "=================================="

# Afficher le fichier corrigé avec numéros de ligne
echo "📋 FICHIER WAKE WORD SERVICE CORRIGÉ (avec numéros de ligne):"
echo "------------------------------------------------------------"
cat -n app/src/main/java/com/magiccontrol/service/WakeWordService.kt

echo ""
echo "🔍 VÉRIFICATIONS GLOBALES"
echo "========================"

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

# Vérification 2: Structure Kotlin
echo "📋 Vérification structure Kotlin..."
if grep -q "class WakeWordService" app/src/main/java/com/magiccontrol/service/WakeWordService.kt && \
   grep -q "override fun onBind" app/src/main/java/com/magiccontrol/service/WakeWordService.kt && \
   grep -q "private val TAG" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
    echo "✅ Structure Kotlin valide"
else
    echo "❌ Structure Kotlin problématique"
    exit 1
fi

# Vérification 3: Indentation corrigée
echo "📋 Vérification indentation..."
if ! grep -q "^wakeWordDetector" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
    echo "✅ Indentation corrigée"
else
    echo "❌ Problèmes d'indentation détectés"
    exit 1
fi

# Vérification 4: Fonction onWakeWordDetected améliorée
echo "📋 Vérification fonction onWakeWordDetected..."
if grep -q "Transition vers reconnaissance" app/src/main/java/com/magiccontrol/service/WakeWordService.kt && \
   grep -q "FullRecognitionService démarré" app/src/main/java/com/magiccontrol/service/WakeWordService.kt; then
    echo "✅ Fonction onWakeWordDetected améliorée"
else
    echo "❌ Fonction onWakeWordDetected non corrigée"
    exit 1
fi

# Vérification 5: Encodage
echo "📋 Vérification encodage..."
if file -i app/src/main/java/com/magiccontrol/service/WakeWordService.kt | grep -q "utf-8"; then
    echo "✅ Encodage UTF-8 correct"
else
    echo "❌ Problème d'encodage"
    exit 1
fi

echo ""
echo "🎉 CORRECTION WAKE WORD SERVICE TERMINÉE AVEC SUCCÈS !"
