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
                    setupTTS(context)
                    isInitialized = true
                    Log.d(TAG, "TTS initialisé avec succès")
                } else {
                    Log.e(TAG, "Erreur initialisation TTS: $status")
                }
            }
        }
    }

    private fun setupTTS(context: Context) {
        val language = when (PreferencesManager.getCurrentLanguage(context)) {
            "fr" -> Locale.FRENCH
            "en" -> Locale.ENGLISH
            else -> Locale.FRENCH
        }

        tts?.language = language
        tts?.setSpeechRate(PreferencesManager.getVoiceSpeed(context) / 100f)
        
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
