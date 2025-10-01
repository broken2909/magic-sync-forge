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
    private val TAG = "TTSManager"

    fun initialize(context: Context) {
        if (tts == null) {
            tts = TextToSpeech(context) { status ->
                if (status == TextToSpeech.SUCCESS) {
                    setupTTSWithSystemLanguage()
                    isInitialized = true
                    Log.d(TAG, "TTS initialisé avec succès")
                } else {
                    Log.e(TAG, "Erreur initialisation TTS: $status")
                }
            }
        }
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
            Log.d(TAG, "Anglais configuré comme fallback")
        }
        // Sinon utiliser la langue par défaut du TTS
        else {
            Log.w(TAG, "Aucune langue disponible - utilisation défaut TTS")
        }
        
        // Configurer la vitesse de parole
        tts?.setSpeechRate(1.0f)
    }

    fun speak(context: Context, text: String) {
        if (!PreferencesManager.isVoiceFeedbackEnabled(context)) {
            return
        }

        if (!isInitialized) {
            initialize(context)
        }

        if (isInitialized && tts != null) {
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
    }

    fun isSpeaking(): Boolean {
        return tts?.isSpeaking ?: false
    }
}
