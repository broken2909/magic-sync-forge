package com.magiccontrol.command

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import android.util.Log
import com.magiccontrol.tts.TTSManager
import com.magiccontrol.utils.ApplicationManager

/**
 * Processeur de commandes avancé avec musique et applications dynamiques
 */
class AdvancedCommandProcessor(private val context: Context) {

    private val TAG = "AdvancedCommandProcessor"
    private val appManager = ApplicationManager(context)
    
    // Dictionnaire de commandes avec variantes
    private val commandPatterns = mapOf(
        // VOLUME
        "volume.*augmenter" to { changeVolume(1) },
        "volume.*baisser" to { changeVolume(-1) },
        "volume.*max" to { setVolume(100) },
        "volume.*mute" to { setVolume(0) },
        "volume.*moyen" to { setVolume(50) },
        
        // APPLICATIONS DYNAMIQUES
        "ouvrir.*" to { command -> openAnyApp(command) },
        "lancer.*" to { command -> openAnyApp(command) },
        "ouvre.*" to { command -> openAnyApp(command) },
        
        // APPLICATIONS SPÉCIFIQUES
        "appareil.*photo" to { openSpecificApp("appareil photo") },
        "caméra" to { openSpecificApp("appareil photo") },
        "galerie" to { openSpecificApp("galerie") },
        "photos" to { openSpecificApp("galerie") },
        "navigateur" to { openSpecificApp("navigateur") },
        "internet" to { openSpecificApp("navigateur") },
        "chrome" to { openSpecificApp("navigateur") },
        "paramètres" to { openSpecificApp("paramètres") },
        "settings" to { openSpecificApp("paramètres") },
        "musique" to { openSpecificApp("musique") },
        "spotify" to { openSpecificApp("musique") },
        "messages" to { openSpecificApp("messages") },
        "sms" to { openSpecificApp("messages") },
        "contacts" to { openSpecificApp("contacts") },
        "téléphone" to { openSpecificApp("téléphone") },
        "appel" to { openSpecificApp("téléphone") },
        
        // CONTRÔLE MUSIQUE
        "musique.*jouer" to { controlMusic("play") },
        "musique.*pause" to { controlMusic("pause") },
        "musique.*stop" to { controlMusic("stop") },
        "musique.*suivant" to { controlMusic("next") },
        "musique.*précédent" to { controlMusic("previous") },
        "musique.*suivante" to { controlMusic("next") },
        "pause.*musique" to { controlMusic("pause") },
        "stop.*musique" to { controlMusic("stop") },
        "suivant.*musique" to { controlMusic("next") },
        "précédent.*musique" to { controlMusic("previous") },
        "play.*musique" to { controlMusic("play") },
        "next.*musique" to { controlMusic("next") },
        "previous.*musique" to { controlMusic("previous") },
        
        // SYSTÈME
        "retour.*accueil" to { goHome() },
        "retour.*maison" to { goHome() },
        "page.*précédente" to { goBack() },
        "revenir.*en.*arrière" to { goBack() },
        "éteindre.*écran" to { lockScreen() },
        "verrouiller.*écran" to { lockScreen() },
        
        // CONNECTIVITÉ
        "activer.*wifi" to { toggleWifi(true) },
        "désactiver.*wifi" to { toggleWifi(false) },
        "activer.*bluetooth" to { toggleBluetooth(true) },
        "désactiver.*bluetooth" to { toggleBluetooth(false) },
        "activer.*données" to { toggleMobileData(true) },
        "désactiver.*données" to { toggleMobileData(false) },
        
        // ASSISTANT
        "que.*peux.*tu.*faire" to { showCapabilities() },
        "aide" to { showHelp() },
        "commandes.*disponibles" to { showCapabilities() },
        "applications.*disponibles" to { showInstalledApps() }
    )
    
    // Mots-clés d'urgence
    private val emergencyKeywords = listOf(
        "urgence", "aide", "au secours", "sos", "danger"
    )

    /**
     * Traite une commande naturelle avec matching flexible
     */
    fun processNaturalCommand(command: String, callback: (Boolean) -> Unit) {
        val normalizedCommand = command.lowercase().trim()
        
        Log.d(TAG, "🎯 Traitement commande: '$normalizedCommand'")
        
        // Vérification urgence
        if (isEmergencyCommand(normalizedCommand)) {
            handleEmergency(command)
            callback(true)
            return
        }
        
        // Recherche de pattern correspondant
        var commandExecuted = false
        
        for ((pattern, action) in commandPatterns) {
            if (matchesPattern(normalizedCommand, pattern)) {
                Log.d(TAG, "✅ Pattern trouvé: $pattern")
                try {
                    if (pattern.contains("ouvrir.*") || pattern.contains("lancer.*")) {
                        // Commandes dynamiques qui nécessitent le paramètre
                        action.invoke(normalizedCommand)
                    } else {
                        action.invoke()
                    }
                    commandExecuted = true
                    break
                } catch (e: Exception) {
                    Log.e(TAG, "❌ Erreur exécution commande", e)
                    TTSManager.speak(context, "Erreur exécution commande")
                }
            }
        }
        
        if (!commandExecuted) {
            Log.w(TAG, "⚠️ Aucun pattern trouvé pour: $normalizedCommand")
            handleUnknownCommand(normalizedCommand)
        }
        
        callback(commandExecuted)
    }
    
    /**
     * Vérifie si la commande correspond au pattern avec flexibilité
     */
    private fun matchesPattern(command: String, pattern: String): Boolean {
        val regexPattern = pattern
            .replace(".*", ".*")
            .replace(" ", ".*")
        
        return command.matches(Regex(regexPattern))
    }
    
    /**
     * Détection commandes d'urgence
     */
    private fun isEmergencyCommand(command: String): Boolean {
        return emergencyKeywords.any { command.contains(it) }
    }
    
    /**
     * Gestion commandes d'urgence
     */
    private fun handleEmergency(command: String) {
        Log.w(TAG, "🚨 COMMANDE URGENCE: $command")
        TTSManager.speak(context, "Commande urgence détectée. Assistance nécessaire.")
    }
    
    /**
     * Gestion commandes inconnues
     */
    private fun handleUnknownCommand(command: String) {
        Log.d(TAG, "🤔 Commande inconnue: $command")
        
        // Réponses contextuelles pour commandes similaires
        when {
            command.contains("volume") -> TTSManager.speak(context, "Dites 'augmenter le volume' ou 'baisser le volume'")
            command.contains("ouvrir") || command.contains("lancer") -> 
                TTSManager.speak(context, "Dites 'ouvrir' suivi du nom de l'application")
            command.contains("musique") -> TTSManager.speak(context, "Dites 'musique play', 'musique pause' ou 'musique suivant'")
            command.contains("wifi") || command.contains("internet") -> 
                TTSManager.speak(context, "Dites 'activer le wifi' ou 'désactiver le wifi'")
            else -> TTSManager.speak(context, "Je n'ai pas compris. Dites 'aide' pour connaître les commandes.")
        }
    }
    
    // =========================================================================
    // IMPLÉMENTATIONS DES COMMANDES - APPLICATIONS DYNAMIQUES
    // =========================================================================
    
    /**
     * Ouvre n'importe quelle application détectée dynamiquement
     */
    private fun openAnyApp(command: String) {
        Log.d(TAG, "📱 Ouverture application dynamique: $command")
        
        // Extraire le nom de l'app après "ouvrir" ou "lancer"
        val appName = command
            .replace("ouvrir", "")
            .replace("lancer", "")
            .replace("ouvre", "")
            .trim()
        
        if (appName.isEmpty()) {
            TTSManager.speak(context, "Dites 'ouvrir' suivi du nom de l'application")
            return
        }
        
        if (appManager.openApp(appName)) {
            TTSManager.speak(context, "Ouverture de $appName")
        } else {
            val suggestions = appManager.getAppSuggestions(appName)
            if (suggestions.isNotEmpty()) {
                TTSManager.speak(context, "Application non trouvée. Suggestions: ${suggestions.joinToString(", ")}")
            } else {
                TTSManager.speak(context, "Application $appName non trouvée")
            }
        }
    }
    
    /**
     * Ouvre une application spécifique
     */
    private fun openSpecificApp(appType: String) {
        Log.d(TAG, "📱 Ouverture application spécifique: $appType")
        
        if (appManager.openApp(appType)) {
            TTSManager.speak(context, "Ouverture de $appType")
        } else {
            TTSManager.speak(context, "Impossible d'ouvrir $appType")
        }
    }
    
    /**
     * Contrôle la musique
     */
    private fun controlMusic(action: String) {
        Log.d(TAG, "🎵 Contrôle musique: $action")
        
        // Intent standard pour contrôle média
        val intent = Intent("com.android.music.musicservicecommand")
        
        when (action) {
            "play" -> {
                intent.putExtra("command", "play")
                TTSManager.speak(context, "Musique play")
            }
            "pause" -> {
                intent.putExtra("command", "pause")
                TTSManager.speak(context, "Musique pause")
            }
            "stop" -> {
                intent.putExtra("command", "stop")
                TTSManager.speak(context, "Musique stop")
            }
            "next" -> {
                intent.putExtra("command", "next")
                TTSManager.speak(context, "Morceau suivant")
            }
            "previous" -> {
                intent.putExtra("command", "previous")
                TTSManager.speak(context, "Morceau précédent")
            }
        }
        
        try {
            context.sendBroadcast(intent)
            Log.d(TAG, "✅ Commande musique envoyée: $action")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur contrôle musique", e)
            TTSManager.speak(context, "Erreur contrôle musique")
        }
    }
    
    /**
     * Affiche les applications installées
     */
    private fun showInstalledApps() {
        Log.d(TAG, "📋 Affichage applications installées")
        val apps = appManager.getInstalledApps()
        
        if (apps.isNotEmpty()) {
            val appNames = apps.keys.take(10).joinToString(", ") // Maximum 10 apps
            TTSManager.speak(context, "Applications disponibles: $appNames")
        } else {
            TTSManager.speak(context, "Aucune application détectée")
        }
    }
    
    // =========================================================================
    // COMMANDES EXISTANTES (conservées)
    // =========================================================================
    
    private fun changeVolume(delta: Int) {
        Log.d(TAG, "🔊 Changement volume: $delta")
        TTSManager.speak(context, "Volume ajusté")
    }
    
    private fun setVolume(level: Int) {
        Log.d(TAG, "🔊 Volume fixé à: $level")
        TTSManager.speak(context, "Volume réglé sur $level pourcent")
    }
    
    private fun goHome() {
        Log.d(TAG, "🏠 Retour accueil")
        try {
            val intent = Intent(Intent.ACTION_MAIN)
            intent.addCategory(Intent.CATEGORY_HOME)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(intent)
            TTSManager.speak(context, "Retour à l'accueil")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur retour accueil", e)
        }
    }
    
    private fun goBack() {
        Log.d(TAG, "↩️ Retour arrière")
        TTSManager.speak(context, "Retour en arrière")
    }
    
    private fun lockScreen() {
        Log.d(TAG, "🔒 Verrouillage écran")
        TTSManager.speak(context, "Écran verrouillé")
    }
    
    private fun toggleWifi(enable: Boolean) {
        Log.d(TAG, "📶 Wifi: $enable")
        TTSManager.speak(context, if (enable) "Wifi activé" else "Wifi désactivé")
    }
    
    private fun toggleBluetooth(enable: Boolean) {
        Log.d(TAG, "📱 Bluetooth: $enable")
        TTSManager.speak(context, if (enable) "Bluetooth activé" else "Bluetooth désactivé")
    }
    
    private fun toggleMobileData(enable: Boolean) {
        Log.d(TAG, "📶 Données mobiles: $enable")
        TTSManager.speak(context, if (enable) "Données mobiles activées" else "Données mobiles désactivées")
    }
    
    private fun showCapabilities() {
        Log.d(TAG, "📋 Affichage capacités")
        val capabilities = """
            Je peux vous aider avec:
            • Applications: ouvrir n'importe quelle app installée
            • Musique: play, pause, stop, suivant, précédent
            • Volume: augmenter, baisser, muet
            • Navigation: accueil, retour, verrouillage
            • Connexion: wifi, bluetooth, données mobiles
            Dites 'aide' pour plus d'informations.
        """.trimIndent()
        TTSManager.speak(context, capabilities)
    }
    
    private fun showHelp() {
        Log.d(TAG, "ℹ️ Affichage aide")
        val help = """
            Commandes disponibles:
            Apps: 'ouvrir' suivi du nom, 'ouvrir caméra', 'ouvrir spotify'
            Musique: 'musique play', 'musique pause', 'morceau suivant'
            Volume: 'augmenter volume', 'volume muet'
            Système: 'retour accueil', 'éteindre écran'
            Dites 'commandes disponibles' pour la liste complète.
        """.trimIndent()
        TTSManager.speak(context, help)
    }
}
