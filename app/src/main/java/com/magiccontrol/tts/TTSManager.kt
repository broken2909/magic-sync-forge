package com.magiccontrol.tts

import android.content.Context
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.util.Log
import com.magiccontrol.utils.PreferencesManager
import java.util.Locale

object TTSManager {
    private var tts: TextToSpeech? = null
    private var isInitialized = false
    private var initializationError: String? = null
    private val TAG = "TTSManager"
    
    // Callback pour notifier l'initialisation
    private var initializationCallbacks = mutableListOf<() -> Unit>()

    fun initialize(context: Context) {
        if (tts == null) {
            tts = TextToSpeech(context) { status ->
                if (status == TextToSpeech.SUCCESS) {
                    setupTTSWithSystemLanguage()
                    isInitialized = true
                    initializationError = null
                    Log.d(TAG, "TTS initialisé avec succès")
                    
                    // Notifier tous les callbacks en attente
                    notifyInitializationCallbacks()
                    
                } else {
                    initializationError = "Error code: $status"
                    Log.e(TAG, "Erreur initialisation TTS: $status")
                }
            }
        }
    }

    /**
     * Vérifie si TTS est initialisé et prêt à parler
     */
    fun isInitialized(): Boolean {
        return isInitialized && tts != null
    }

    /**
     * Retourne l'erreur d'initialisation si applicable
     */
    fun getInitializationError(): String? {
        return initializationError
    }

    /**
     * Ajoute un callback à appeler quand TTS est initialisé
     */
    fun addInitializationCallback(callback: () -> Unit) {
        if (isInitialized) {
            callback()
        } else {
            initializationCallbacks.add(callback)
        }
    }

    private fun notifyInitializationCallbacks() {
        val callbacks = initializationCallbacks.toList()
        initializationCallbacks.clear()
        callbacks.forEach { it() }
    }

    private fun setupTTSWithSystemLanguage() {
        val systemLocale = Locale.getDefault()
        
        // Vérifier les langues disponibles dans TTS
        val availableLanguages = tts?.availableLanguages ?: emptySet()
        Log.d(TAG, "Langues disponibles TTS: $availableLanguages")
        Log.d(TAG, "Langue système: $systemLocale")
        
        // Essayer la langue système exacte
        if (availableLanguages.contains(systemLocale)) {
            tts?.language = systemLocale
            Log.d(TAG, "Langue système configurée: $systemLocale")
        }
        // Sinon essayer la langue de base (sans pays)
        else if (availableLanguages.contains(Locale(systemLocale.language))) {
            tts?.language = Locale(systemLocale.language)
            Log.d(TAG, "Langue de base configurée: ${systemLocale.language}")
        }
        // Sinon utiliser l'anglais comme fallback
        else if (availableLanguages.contains(Locale.ENGLISH)) {
            tts?.language = Locale.ENGLISH
            Log.d(TAG, "Fallback anglais configuré")
        }
        // Sinon utiliser la première langue disponible
        else if (availableLanguages.isNotEmpty()) {
            tts?.language = availableLanguages.first()
            Log.d(TAG, "Première langue disponible configurée: ${availableLanguages.first()}")
        }
        
        // Configuration de base
        tts?.setSpeechRate(0.8f)
        tts?.setPitch(0.9f)
        
        tts?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
            override fun onStart(utteranceId: String?) {
                Log.d(TAG, "TTS started: $utteranceId")
            }
            
            override fun onDone(utteranceId: String?) {
                Log.d(TAG, "TTS completed: $utteranceId")
            }
            
            override fun onError(utteranceId: String?) {
                Log.e(TAG, "TTS error: $utteranceId")
            }
        })
        
        Log.d(TAG, "TTS final - Langue: ${tts?.language}, Pays: ${tts?.language?.country}")
    }

    fun speak(context: Context, text: String) {
        if (!PreferencesManager.isVoiceFeedbackEnabled(context)) {
            return
        }
        
        if (!isInitialized) {
            initialize(context)
            // Ajouter un callback pour parler une fois initialisé
            addInitializationCallback {
                doSpeak(text)
            }
        } else {
            doSpeak(text)
        }
    }

    private fun doSpeak(text: String) {
        if (isInitialized && tts != null) {
            Log.d(TAG, "Speaking: $text (langue: ${tts?.language})")
            tts?.speak(text, TextToSpeech.QUEUE_ADD, null, "tts_utterance")
        } else {
            Log.w(TAG, "TTS non initialisé pour: $text")
        }
    }

    fun stop() {
        tts?.stop()
    }

    fun shutdown() {
        tts?.shutdown()
        tts = null
        isInitialized = false
        initializationError = null
        initializationCallbacks.clear()
    }

    fun isSpeaking(): Boolean {
        return tts?.isSpeaking ?: false
    }
    
    /**
     * Retourne la langue actuellement configurée dans TTS
     */
    fun getCurrentLanguage(): String {
        return tts?.language?.language ?: "en"
    }
    
    /**
     * Définit la vitesse de la voix (0-100%)
     */
    fun setVoiceSpeed(context: Context, speedPercent: Int) {
        val speed = (speedPercent / 100.0f).coerceIn(0.1f, 3.0f)
        tts?.setSpeechRate(speed)
        Log.d(TAG, "Vitesse TTS ajustée: $speedPercent% -> $speed")
    }
    
    /**
     * Met à jour les paramètres TTS selon les préférences
     */
    fun updateFromPreferences(context: Context) {
        if (isInitialized) {
            val speed = PreferencesManager.getVoiceSpeed(context)
            setVoiceSpeed(context, speed)
            Log.d(TAG, "Paramètres TTS mis à jour depuis préférences")
        }
    }
}
