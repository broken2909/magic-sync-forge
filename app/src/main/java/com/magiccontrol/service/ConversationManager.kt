package com.magiccontrol.service

import android.content.Context
import android.util.Log
import com.magiccontrol.tts.TTSManager
import com.magiccontrol.utils.PreferencesManager
import com.magiccontrol.command.CommandProcessor
import org.vosk.Model
import org.vosk.Recognizer
import org.json.JSONObject
import java.io.File

/**
 * Gestionnaire unifié de conversation avec intégration VOSK
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
    
    // Composants VOSK
    private var voskModel: Model? = null
    private var voskRecognizer: Recognizer? = null
    private var voskInitialized = false
    
    // Gestion conversation
    private var currentState = ConversationState.LISTENING_WAKE_WORD
    private var commandProcessor: CommandProcessor? = null
    private var lastWakeWordTime = 0L
    private val WAKE_WORD_COOLDOWN = 3000L // 3 secondes
    
    // Configuration audio
    private val sampleRate = 16000
    
    init {
        commandProcessor = CommandProcessor(context)
        initializeVosk()
    }

    /**
     * Initialise le modèle VOSK
     */
    private fun initializeVosk(): Boolean {
        return try {
            Log.d(TAG, "🔄 Initialisation VOSK...")
            
            val currentLanguage = PreferencesManager.getCurrentLanguage(context)
            val modelPath = File(context.filesDir, "models/$currentLanguage-small").absolutePath
            
            if (!File(modelPath).exists()) {
                Log.e(TAG, "❌ Modèle VOSK manquant: $modelPath")
                // Fallback
                val fallbackPath = File(context.filesDir, "models/fr-small").absolutePath
                if (!File(fallbackPath).exists()) {
                    Log.e(TAG, "❌ Modèle fallback aussi manquant")
                    return false
                }
            }
            
            voskModel = Model(modelPath)
            voskRecognizer = Recognizer(voskModel, sampleRate.toFloat())
            
            voskInitialized = true
            Log.d(TAG, "✅ VOSK initialisé - Langue: $currentLanguage")
            true
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur initialisation VOSK", e)
            false
        }
    }

    /**
     * Traite un buffer audio via VOSK et gère la conversation
     */
    fun processAudio(buffer: ByteArray, bytesRead: Int) {
        if (!voskInitialized) {
            Log.w(TAG, "⏸️ VOSK non initialisé")
            return
        }
        
        try {
            val recognizer = voskRecognizer ?: return
            
            // Traitement VOSK
            if (recognizer.acceptWaveForm(buffer, bytesRead)) {
                // Résultat final
                val result = recognizer.result
                processVoskResult(result, isFinal = true)
            } else {
                // Résultat partiel
                val partialResult = recognizer.partialResult
                if (partialResult.isNotEmpty()) {
                    processVoskResult(partialResult, isFinal = false)
                }
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur traitement VOSK", e)
        }
    }
    
    /**
     * Traite le résultat VOSK selon l'état conversationnel
     */
    private fun processVoskResult(result: String, isFinal: Boolean) {
        try {
            if (result.isEmpty() || result == "{}") return
            
            val json = JSONObject(result)
            val text = if (isFinal) {
                json.optString("text", "").trim()
            } else {
                json.optString("partial", "").trim()
            }
            
            if (text.isNotEmpty()) {
                Log.d(TAG, "🎯 VOSK ${if (isFinal) "Final" else "Partiel"}: '$text'")
                
                when (currentState) {
                    ConversationState.LISTENING_WAKE_WORD -> {
                        if (isWakeWordDetected(text) && isWakeWordCooldownOver()) {
                            onWakeWordDetected()
                        }
                    }
                    
                    ConversationState.LISTENING_COMMAND -> {
                        if (isFinal && text.isNotEmpty()) {
                            onCommandDetected(text)
                        }
                    }
                    
                    ConversationState.SPEAKING -> {
                        Log.d(TAG, "⏸️ Audio ignoré (assistant parle)")
                    }
                    
                    ConversationState.PROCESSING_COMMAND -> {
                        Log.d(TAG, "⏸️ Audio ignoré (traitement commande)")
                    }
                }
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur traitement résultat VOSK", e)
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
        
        try {
            voskRecognizer = null
            voskModel?.close()
            voskModel = null
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur cleanup VOSK", e)
        }
    }
}
