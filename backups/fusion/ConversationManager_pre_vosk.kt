package com.magiccontrol.service

import android.content.Context
import android.util.Log
import com.magiccontrol.tts.TTSManager
import com.magiccontrol.utils.PreferencesManager
import com.magiccontrol.command.CommandProcessor

/**
 * Gestionnaire unifié de conversation
 * Fusionne la détection du mot-clé et l'interaction utilisateur
 */
class ConversationManager(private val context: Context) {

    private val TAG = "ConversationManager"
    
    // États de conversation
    enum class ConversationState {
        LISTENING_WAKE_WORD,    // Écoute "Magic"
        LISTENING_COMMAND,      // Écoute commande utilisateur
        SPEAKING,               // Assistant parle (ignore audio)
        PROCESSING_COMMAND      // Exécution commande en cours
    }
    
    private var currentState = ConversationState.LISTENING_WAKE_WORD
    private var commandProcessor: CommandProcessor? = null
    private var lastWakeWordTime = 0L
    private val WAKE_WORD_COOLDOWN = 3000L // 3 secondes
    
    init {
        commandProcessor = CommandProcessor(context)
    }

    /**
     * Traite un buffer audio selon l'état actuel
     */
    fun processAudio(buffer: ByteArray, voskText: String, isFinal: Boolean) {
        when (currentState) {
            ConversationState.LISTENING_WAKE_WORD -> {
                if (isWakeWordDetected(voskText) && isWakeWordCooldownOver()) {
                    onWakeWordDetected()
                }
            }
            
            ConversationState.LISTENING_COMMAND -> {
                if (isFinal && voskText.isNotEmpty()) {
                    onCommandDetected(voskText)
                }
            }
            
            ConversationState.SPEAKING -> {
                // Ignorer l'audio pendant que l'assistant parle
                Log.d(TAG, "⏸️ Audio ignoré (assistant parle)")
            }
            
            ConversationState.PROCESSING_COMMAND -> {
                // Ignorer l'audio pendant l'exécution
                Log.d(TAG, "⏸️ Audio ignoré (traitement commande)")
            }
        }
    }
    
    /**
     * Vérifie si le mot-clé est détecté dans le texte
     */
    private fun isWakeWordDetected(text: String): Boolean {
        val keyword = PreferencesManager.getActivationKeyword(context).lowercase().trim()
        val normalizedText = text.lowercase().trim()
        
        // Liste des variantes acceptées
        val keywordVariants = if (keyword == "magic") listOf(
            "magic", "maagic", "magique", "maagique",
            "magik", "maagik", "majic", "maggic"
        ) else listOf(keyword)
        
        return keywordVariants.any { variant ->
            normalizedText.contains(variant) || 
            normalizedText.split(" ").any { word ->
                word == variant || calculateSimilarity(word, variant) > 0.85
            }
        }
    }
    
    /**
     * Évite les détections trop rapprochées
     */
    private fun isWakeWordCooldownOver(): Boolean {
        val now = System.currentTimeMillis()
        return (now - lastWakeWordTime) > WAKE_WORD_COOLDOWN
    }
    
    /**
     * Appelé quand "Magic" est détecté
     */
    private fun onWakeWordDetected() {
        Log.d(TAG, "🎯 MOT-CLÉ DÉTECTÉ - Début interaction")
        lastWakeWordTime = System.currentTimeMillis()
        currentState = ConversationState.SPEAKING
        
        // Réponse vocale
        TTSManager.speak(context, "Oui?")
        
        // Transition vers écoute commande après délai TTS
        android.os.Handler(context.mainLooper).postDelayed({
            currentState = ConversationState.LISTENING_COMMAND
            Log.d(TAG, "🔊 En écoute pour commande...")
        }, 1500L)
    }
    
    /**
     * Appelé quand une commande est détectée
     */
    private fun onCommandDetected(command: String) {
        Log.d(TAG, "🎯 COMMANDE DÉTECTÉE: '$command'")
        currentState = ConversationState.PROCESSING_COMMAND
        
        // Exécuter la commande
        commandProcessor?.processCommand(command) { success ->
            if (success) {
                Log.d(TAG, "✅ Commande exécutée avec succès")
            } else {
                Log.w(TAG, "⚠️ Commande non reconnue")
                TTSManager.speak(context, "Commande non reconnue")
            }
            
            // Retour à l'écoute du mot-clé
            android.os.Handler(context.mainLooper).postDelayed({
                currentState = ConversationState.LISTENING_WAKE_WORD
                Log.d(TAG, "🔍 Retour écoute mot-clé")
            }, 1000L)
        }
    }
    
    /**
     * Calcule la similarité entre deux mots
     */
    private fun calculateSimilarity(s1: String, s2: String): Double {
        if (s1 == s2) return 1.0
        if (s1.isEmpty() || s2.isEmpty()) return 0.0
        
        val longer = if (s1.length > s2.length) s1 else s2
        val shorter = if (s1.length > s2.length) s2 else s1
        
        return if (longer.length == 0) 1.0
        else (longer.length - editDistance(longer, shorter)) / longer.length.toDouble()
    }
    
    private fun editDistance(s1: String, s2: String): Int {
        val dp = Array(s1.length + 1) { IntArray(s2.length + 1) }
        
        for (i in 0..s1.length) dp[i][0] = i
        for (j in 0..s2.length) dp[0][j] = j
        
        for (i in 1..s1.length) {
            for (j in 1..s2.length) {
                val cost = if (s1[i-1] == s2[j-1]) 0 else 1
                dp[i][j] = minOf(
                    dp[i-1][j] + 1,
                    dp[i][j-1] + 1, 
                    dp[i-1][j-1] + cost
                )
            }
        }
        
        return dp[s1.length][s2.length]
    }
    
    /**
     * Force l'arrêt de la conversation (quitter l'application)
     */
    fun stop() {
        currentState = ConversationState.LISTENING_WAKE_WORD
        commandProcessor = null
    }
}
