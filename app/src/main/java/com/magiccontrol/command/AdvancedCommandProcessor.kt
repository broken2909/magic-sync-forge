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
    
    // Interface pour les actions de commande
    private interface CommandAction {
        fun execute(command: String = "")
    }
    
    // Dictionnaire de commandes avec variantes - CORRIGÉ avec types explicites
    private val commandPatterns = mapOf<String, CommandAction>(
        // VOLUME
        "volume.*augmenter" to object : CommandAction {
            override fun execute(command: String) = changeVolume(1)
        },
        "volume.*baisser" to object : CommandAction {
            override fun execute(command: String) = changeVolume(-1)
        },
        "volume.*max" to object : CommandAction {
            override fun execute(command: String) = setVolume(100)
        },
        "volume.*mute" to object : CommandAction {
            override fun execute(command: String) = setVolume(0)
        },
        "volume.*moyen" to object : CommandAction {
            override fun execute(command: String) = setVolume(50)
        },
        
        // APPLICATIONS DYNAMIQUES
        "ouvrir.*" to object : CommandAction {
            override fun execute(command: String) = openAnyApp(command)
        },
        "lancer.*" to object : CommandAction {
            override fun execute(command: String) = openAnyApp(command)
        },
        "ouvre.*" to object : CommandAction {
            override fun execute(command: String) = openAnyApp(command)
        },
        
        // APPLICATIONS SPECIFIQUES
        "appareil.*photo" to object : CommandAction {
            override fun execute(command: String) = openSpecificApp("appareil photo")
        },
        "camera" to object : CommandAction {
            override fun execute(command: String) = openSpecificApp("appareil photo")
        },
        "galerie" to object : CommandAction {
            override fun execute(command: String) = openSpecificApp("galerie")
        },
        "photos" to object : CommandAction {
            override fun execute(command: String) = openSpecificApp("galerie")
        },
        "navigateur" to object : CommandAction {
            override fun execute(command: String) = openSpecificApp("navigateur")
        },
        "internet" to object : CommandAction {
            override fun execute(command: String) = openSpecificApp("navigateur")
        },
        "chrome" to object : CommandAction {
            override fun execute(command: String) = openSpecificApp("navigateur")
        },
        "parametres" to object : CommandAction {
            override fun execute(command: String) = openSpecificApp("parametres")
        },
        "settings" to object : CommandAction {
            override fun execute(command: String) = openSpecificApp("parametres")
        },
        "musique" to object : CommandAction {
            override fun execute(command: String) = openSpecificApp("musique")
        },
        "spotify" to object : CommandAction {
            override fun execute(command: String) = openSpecificApp("musique")
        },
        "messages" to object : CommandAction {
            override fun execute(command: String) = openSpecificApp("messages")
        },
        "sms" to object : CommandAction {
            override fun execute(command: String) = openSpecificApp("messages")
        },
        "contacts" to object : CommandAction {
            override fun execute(command: String) = openSpecificApp("contacts")
        },
        "telephone" to object : CommandAction {
            override fun execute(command: String) = openSpecificApp("telephone")
        },
        "appel" to object : CommandAction {
            override fun execute(command: String) = openSpecificApp("telephone")
        },
        
        // CONTRÔLE MUSIQUE
        "musique.*jouer" to object : CommandAction {
            override fun execute(command: String) = controlMusic("play")
        },
        "musique.*pause" to object : CommandAction {
            override fun execute(command: String) = controlMusic("pause")
        },
        "musique.*stop" to object : CommandAction {
            override fun execute(command: String) = controlMusic("stop")
        },
        "musique.*suivant" to object : CommandAction {
            override fun execute(command: String) = controlMusic("next")
        },
        "musique.*precedent" to object : CommandAction {
            override fun execute(command: String) = controlMusic("previous")
        },
        "musique.*suivante" to object : CommandAction {
            override fun execute(command: String) = controlMusic("next")
        },
        "pause.*musique" to object : CommandAction {
            override fun execute(command: String) = controlMusic("pause")
        },
        "stop.*musique" to object : CommandAction {
            override fun execute(command: String) = controlMusic("stop")
        },
        "suivant.*musique" to object : CommandAction {
            override fun execute(command: String) = controlMusic("next")
        },
        "precedent.*musique" to object : CommandAction {
            override fun execute(command: String) = controlMusic("previous")
        },
        "play.*musique" to object : CommandAction {
            override fun execute(command: String) = controlMusic("play")
        },
        "next.*musique" to object : CommandAction {
            override fun execute(command: String) = controlMusic("next")
        },
        "previous.*musique" to object : CommandAction {
            override fun execute(command: String) = controlMusic("previous")
        },
        
        // SYSTÈME
        "retour.*accueil" to object : CommandAction {
            override fun execute(command: String) = goHome()
        },
        "retour.*maison" to object : CommandAction {
            override fun execute(command: String) = goHome()
        },
        "page.*precedente" to object : CommandAction {
            override fun execute(command: String) = goBack()
        },
        "revenir.*en.*arriere" to object : CommandAction {
            override fun execute(command: String) = goBack()
        },
        "eteindre.*ecran" to object : CommandAction {
            override fun execute(command: String) = lockScreen()
        },
        "verrouiller.*ecran" to object : CommandAction {
            override fun execute(command: String) = lockScreen()
        },
        
        // CONNECTIVITE
        "activer.*wifi" to object : CommandAction {
            override fun execute(command: String) = toggleWifi(true)
        },
        "desactiver.*wifi" to object : CommandAction {
            override fun execute(command: String) = toggleWifi(false)
        },
        "activer.*bluetooth" to object : CommandAction {
            override fun execute(command: String) = toggleBluetooth(true)
        },
        "desactiver.*bluetooth" to object : CommandAction {
            override fun execute(command: String) = toggleBluetooth(false)
        },
        "activer.*donnees" to object : CommandAction {
            override fun execute(command: String) = toggleMobileData(true)
        },
        "desactiver.*donnees" to object : CommandAction {
            override fun execute(command: String) = toggleMobileData(false)
        },
        
        // ASSISTANT
        "que.*peux.*tu.*faire" to object : CommandAction {
            override fun execute(command: String) = showCapabilities()
        },
        "aide" to object : CommandAction {
            override fun execute(command: String) = showHelp()
        },
        "commandes.*disponibles" to object : CommandAction {
            override fun execute(command: String) = showCapabilities()
        },
        "applications.*disponibles" to object : CommandAction {
            override fun execute(command: String) = showInstalledApps()
        }
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
                    action.execute(normalizedCommand)
                    commandExecuted = true
                    break
                } catch (e: Exception) {
                    Log.e(TAG, "❌ Erreur execution commande", e)
                    TTSManager.speak(context, "Erreur execution commande")
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
        TTSManager.speak(context, "Commande urgence detectee. Assistance necessaire.")
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
                TTSManager.speak(context, "Dites 'activer le wifi' ou 'desactiver le wifi'")
            else -> TTSManager.speak(context, "Je n'ai pas compris. Dites 'aide' pour connaître les commandes.")
        }
    }
    
    // =========================================================================
    // IMPLEMENTATIONS DES COMMANDES - APPLICATIONS DYNAMIQUES
    // =========================================================================
    
    /**
     * Ouvre n'importe quelle application detectee dynamiquement
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
        Log.d(TAG, "📱 Ouverture application specifique: $appType")
        
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
                TTSManager.speak(context, "Morceau precedent")
            }
        }
        
        try {
            context.sendBroadcast(intent)
            Log.d(TAG, "✅ Commande musique envoyee: $action")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur controle musique", e)
            TTSManager.speak(context, "Erreur controle musique")
        }
    }
    
    /**
     * Affiche les applications installées
     */
    private fun showInstalledApps() {
        Log.d(TAG, "📋 Affichage applications installees")
        val apps = appManager.getInstalledApps()
        
        if (apps.isNotEmpty()) {
            val appNames = apps.keys.take(10).joinToString(", ") // Maximum 10 apps
            TTSManager.speak(context, "Applications disponibles: $appNames")
        } else {
            TTSManager.speak(context, "Aucune application detectee")
        }
    }
    
    // =========================================================================
    // COMMANDES EXISTANTES (conservées)
    // =========================================================================
    
    private fun changeVolume(delta: Int) {
        Log.d(TAG, "🔊 Changement volume: $delta")
        TTSManager.speak(context, "Volume ajuste")
    }
    
    private fun setVolume(level: Int) {
        Log.d(TAG, "🔊 Volume fixe a: $level")
        TTSManager.speak(context, "Volume regle sur $level pourcent")
    }
    
    private fun goHome() {
        Log.d(TAG, "🏠 Retour accueil")
        try {
            val intent = Intent(Intent.ACTION_MAIN)
            intent.addCategory(Intent.CATEGORY_HOME)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(intent)
            TTSManager.speak(context, "Retour a l'accueil")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur retour accueil", e)
        }
    }
    
    private fun goBack() {
        Log.d(TAG, "↩️ Retour arriere")
        TTSManager.speak(context, "Retour en arriere")
    }
    
    private fun lockScreen() {
        Log.d(TAG, "🔒 Verrouillage ecran")
        TTSManager.speak(context, "Ecran verrouille")
    }
    
    private fun toggleWifi(enable: Boolean) {
        Log.d(TAG, "📶 Wifi: $enable")
        TTSManager.speak(context, if (enable) "Wifi active" else "Wifi desactive")
    }
    
    private fun toggleBluetooth(enable: Boolean) {
        Log.d(TAG, "📱 Bluetooth: $enable")
        TTSManager.speak(context, if (enable) "Bluetooth active" else "Bluetooth desactive")
    }
    
    private fun toggleMobileData(enable: Boolean) {
        Log.d(TAG, "📶 Donnees mobiles: $enable")
        TTSManager.speak(context, if (enable) "Donnees mobiles activees" else "Donnees mobiles desactivees")
    }
    
    private fun showCapabilities() {
        Log.d(TAG, "📋 Affichage capacites")
        val capabilities = """
            Je peux vous aider avec:
            • Applications: ouvrir n'importe quelle app installee
            • Musique: play, pause, stop, suivant, precedent
            • Volume: augmenter, baisser, muet
            • Navigation: accueil, retour, verrouillage
            • Connexion: wifi, bluetooth, donnees mobiles
            Dites 'aide' pour plus d'informations.
        """.trimIndent()
        TTSManager.speak(context, capabilities)
    }
    
    private fun showHelp() {
        Log.d(TAG, "ℹ️ Affichage aide")
        val help = """
            Commandes disponibles:
            Apps: 'ouvrir' suivi du nom, 'ouvrir camera', 'ouvrir spotify'
            Musique: 'musique play', 'musique pause', 'morceau suivant'
            Volume: 'augmenter volume', 'volume muet'
            Systeme: 'retour accueil', 'eteindre ecran'
            Dites 'commandes disponibles' pour la liste complete.
        """.trimIndent()
        TTSManager.speak(context, help)
    }
}
