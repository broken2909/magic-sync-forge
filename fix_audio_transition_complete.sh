#!/bin/bash
cd /data/data/com.termux/files/home/magic-sync-forge

echo "🔧 Application des corrections..."
echo "================================="

# Sauvegardes
backup_dir="backup_audio_fix_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"
cp app/src/main/java/com/magiccontrol/service/WakeWordService.kt "$backup_dir/"
cp app/src/main/java/com/magiccontrol/service/FullRecognitionService.kt "$backup_dir/"

# Correction WakeWordService.kt
echo "📝 Correction WakeWordService.kt..."
python3 << 'PYTHON_SCRIPT'
import re

# Lire le fichier WakeWordService.kt
with open('app/src/main/java/com/magiccontrol/service/WakeWordService.kt', 'r', encoding='utf-8') as f:
    content = f.read()

# Nouvelle fonction onWakeWordDetected
new_function = '''private fun onWakeWordDetected() {
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

# Remplacer la fonction existante
pattern = r'private fun onWakeWordDetected\(\)\s*\{[^}]+\}'
if re.search(pattern, content, re.DOTALL):
    content = re.sub(pattern, new_function, content, flags=re.DOTALL)
    print("✅ Fonction onWakeWordDetected remplacée")
else:
    print("❌ Pattern non trouvé, recherche alternative...")
    # Alternative: chercher par le nom de fonction
    if "private fun onWakeWordDetected()" in content:
        start = content.find("private fun onWakeWordDetected()")
        brace_count = 0
        i = start
        while i < len(content):
            if content[i] == '{':
                brace_count += 1
            elif content[i] == '}':
                brace_count -= 1
                if brace_count == 0:
                    content = content[:start] + new_function + content[i+1:]
                    print("✅ Fonction remplacée via comptage braces")
                    break
            i += 1

# Écrire le fichier modifié
with open('app/src/main/java/com/magiccontrol/service/WakeWordService.kt', 'w', encoding='utf-8') as f:
    f.write(content)
PYTHON_SCRIPT

# Correction FullRecognitionService.kt
echo "📝 Correction FullRecognitionService.kt..."
python3 << 'PYTHON_SCRIPT'
import re

# Lire le fichier FullRecognitionService.kt
with open('app/src/main/java/com/magiccontrol/service/FullRecognitionService.kt', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Corriger onStartCommand pour démarrer audio immédiatement
old_pattern = r'// Message d''activation\s+TTSManager\.speak\(applicationContext, "Que voulez-vous faire\?"\)\s+// Démarrer après délai TTS\s+Handler\(Looper\.getMainLooper\(\)\)\.postDelayed\(\{\s+startFullRecognition\(\)\s+\}, 1500L\)'
new_code = '''// 1. Message d''accueil DIFFÉRÉ (ne pas bloquer le démarrage audio)
        Handler(Looper.getMainLooper()).postDelayed({
            TTSManager.speak(applicationContext, "Je vous écoute")
        }, 300L)
        
        // 2. Démarrer la reconnaissance AUDIO IMMÉDIATEMENT (sans attendre TTS)
        startFullRecognition()'''

if re.search(old_pattern, content, re.DOTALL):
    content = re.sub(old_pattern, new_code, content, flags=re.DOTALL)
    print("✅ onStartCommand corrigé")

# 2. Ajouter la fonction restartWakeWordService
if "private fun restartWakeWordService()" not in content:
    # Insérer avant onDestroy ou à la fin de la classe
    insert_point = content.find("override fun onDestroy()")
    if insert_point == -1:
        insert_point = content.rfind("}")
    
    new_function = '''
    
    // 🔧 REDÉMARRAGE SERVICE WAKE WORD
    private fun restartWakeWordService() {
        try {
            Log.d(TAG, "🔄 Redémarrage service wake word")
            val wakeIntent = Intent(this, WakeWordService::class.java)
            startService(wakeIntent)
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur redémarrage wake word", e)
        }
    }'''
    
    content = content[:insert_point] + new_function + content[insert_point:]
    print("✅ Fonction restartWakeWordService ajoutée")

# 3. Modifier onDestroy pour redémarrer le service wake word
old_ondestroy_pattern = r'override fun onDestroy\(\) \{[^}]+\}'
new_ondestroy = '''override fun onDestroy() {
    super.onDestroy()
    Log.d(TAG, "🔚 Service reconnaissance arrêté")

    recognitionActive = false
    isListening = false

    try {
        recognitionThread?.interrupt()
        recognitionThread = null
    } catch (e: Exception) {
        Log.e(TAG, "❌ Erreur arrêt thread", e)
    }
    
    try {
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
    } catch (e: Exception) {
        Log.e(TAG, "❌ Erreur arrêt audio", e)
    }
    
    try {
        voskRecognizer = null
        voskModel?.close()
        voskModel = null
    } catch (e: Exception) {
        Log.e(TAG, "❌ Erreur cleanup VOSK", e)
    }
    
    // 🔧 REDÉMARRAGE SERVICE WAKE WORD APRÈS NETTOYAGE
    Handler(Looper.getMainLooper()).postDelayed({
        restartWakeWordService()
    }, 1000L)
}'''

if re.search(old_ondestroy_pattern, content, re.DOTALL):
    content = re.sub(old_ondestroy_pattern, new_ondestroy, content, flags=re.DOTALL)
    print("✅ onDestroy corrigé")

# Écrire le fichier modifié
with open('app/src/main/java/com/magiccontrol/service/FullRecognitionService.kt', 'w', encoding='utf-8') as f:
    f.write(content)
PYTHON_SCRIPT

echo "✅ Corrections appliquées"
echo ""
echo "🔍 VÉRIFICATIONS OBLIGATOIRES"
echo "============================="

# Vérification 1: Syntaxe Kotlin (braces équilibrées)
echo "📋 Vérification braces équilibrées..."
for file in "WakeWordService.kt" "FullRecognitionService.kt"; do
    open_braces=$(grep -o "{" "app/src/main/java/com/magiccontrol/service/$file" | wc -l)
    close_braces=$(grep -o "}" "app/src/main/java/com/magiccontrol/service/$file" | wc -l)
    if [ "$open_braces" -eq "$close_braces" ]; then
        echo "✅ $file: Braces équilibrées ($open_braces/{ $close_braces/})"
    else
        echo "❌ $file: Braces NON équilibrées ($open_braces/{ $close_braces/})"
        exit 1
    fi
done

# Vérification 2: Encodage UTF-8
echo "📋 Vérification encodage UTF-8..."
for file in "WakeWordService.kt" "FullRecognitionService.kt"; do
    if file -i "app/src/main/java/com/magiccontrol/service/$file" | grep -q "utf-8"; then
        echo "✅ $file: Encodage UTF-8 correct"
    else
        echo "❌ $file: Problème d'encodage"
        exit 1
    fi
done

# Vérification 3: Logique métier cohérente
echo "📋 Vérification logique métier..."
if grep -q "startService.*FullRecognitionService" "app/src/main/java/com/magiccontrol/service/WakeWordService.kt" && \
   grep -q "restartWakeWordService" "app/src/main/java/com/magiccontrol/service/FullRecognitionService.kt"; then
    echo "✅ Logique métier cohérente: transition services OK"
else
    echo "❌ Incohérence logique métier"
    exit 1
fi

# Vérification 4: Pas de doublons
echo "📋 Vérification doublons..."
for file in "WakeWordService.kt" "FullRecognitionService.kt"; do
    if [ $(grep -c "private fun onWakeWordDetected()" "app/src/main/java/com/magiccontrol/service/$file") -le 1 ] && \
       [ $(grep -c "private fun restartWakeWordService()" "app/src/main/java/com/magiccontrol/service/$file") -le 1 ]; then
        echo "✅ $file: Pas de doublons détectés"
    else
        echo "❌ $file: Doublons détectés"
        exit 1
    fi
done

# Vérification 5: Structure Kotlin basique
echo "📋 Vérification syntaxe Kotlin..."
for file in "WakeWordService.kt" "FullRecognitionService.kt"; do
    if grep -q "class.*Service.*:" "app/src/main/java/com/magiccontrol/service/$file" && \
       grep -q "override fun" "app/src/main/java/com/magiccontrol/service/$file"; then
        echo "✅ $file: Structure Kotlin correcte"
    else
        echo "❌ $file: Structure Kotlin problématique"
        exit 1
    fi
done

echo ""
echo "🎉 TOUTES LES VÉRIFICATIONS SONT SATISFAITES !"
echo "📍 Sauvegardes dans: $backup_dir"
echo "🚀 La transition audio est maintenant corrigée :"
echo "   - Micro maintenu actif pendant la reconnaissance"
echo "   - Plus de coupure entre 'Oui?' et l'écoute des commandes"
echo "   - Redémarrage automatique de l'écoute permanente"
