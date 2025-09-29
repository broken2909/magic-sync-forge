#!/bin/bash
echo "🗑️ SUPPRESSION SIMULATION TTS - RESPECT Z.ai"

# Rétablir TTSManager avec détection AUTO SANS liste de langues
cat > app/src/main/java/com/magiccontrol/tts/TTSManager.kt << 'TTS'
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
        // ✅ DÉTECTION 100% AUTOMATIQUE - PAS DE LISTE DE LANGUES
        val systemLocale = Locale.getDefault()
        tts?.language = systemLocale
        
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
        
        Log.d(TAG, "TTS configuré avec langue système: $systemLocale")
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
TTS

echo "✅ SIMULATION SUPPRIMÉE!"
echo "📊 TTSManager maintenant:"
echo "   - ✅ Utilise Locale.getDefault() DIRECTEMENT"
echo "   - ✅ ZERO liste de langues hardcodée"
echo "   - ✅ 100% détection automatique système"
echo "   - ✅ RESPECT architecture Z.ai"
echo ""
echo "🚀 TTS Android gère TOUTES les langues automatiquement!"
