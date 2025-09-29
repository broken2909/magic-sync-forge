#!/bin/bash
echo "🔧 CORRECTION TTS PROFESSIONNEL - DÉTECTION RÉELLE"

# Recréer TTSManager avec gestion propre des langues
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
        
        // ✅ 1. Vérifier les langues disponibles dans TTS
        val availableLanguages = tts?.availableLanguages ?: emptySet()
        Log.d(TAG, "Langues disponibles TTS: $availableLanguages")
        Log.d(TAG, "Langue système: $systemLocale")
        
        // ✅ 2. Essayer la langue système exacte
        if (availableLanguages.contains(systemLocale)) {
            tts?.language = systemLocale
            Log.d(TAG, "Langue système configurée: $systemLocale")
        } 
        // ✅ 3. Sinon essayer la langue de base (sans pays)
        else if (availableLanguages.contains(Locale(systemLocale.language))) {
            tts?.language = Locale(systemLocale.language)
            Log.d(TAG, "Langue de base configurée: ${systemLocale.language}")
        }
        // ✅ 4. Sinon utiliser l'anglais comme fallback
        else if (availableLanguages.contains(Locale.ENGLISH)) {
            tts?.language = Locale.ENGLISH
            Log.d(TAG, "Fallback anglais configuré")
        }
        // ✅ 5. Sinon utiliser la première langue disponible
        else if (availableLanguages.isNotEmpty()) {
            tts?.language = availableLanguages.first()
            Log.d(TAG, "Première langue disponible configurée: ${availableLanguages.first()}")
        }
        
        // ✅ Configuration de base
        tts?.setSpeechRate(1.0f) // Vitesse normale
        tts?.setPitch(1.0f)      // Ton normal
        
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
        
        // ✅ Log final
        Log.d(TAG, "TTS final - Langue: ${tts?.language}, Pays: ${tts?.language?.country}")
    }

    fun speak(context: Context, text: String) {
        if (!PreferencesManager.isVoiceFeedbackEnabled(context)) {
            return
        }

        if (!isInitialized) {
            initialize(context)
            // Attendre un peu que TTS s'initialise
            android.os.Handler().postDelayed({
                doSpeak(text)
            }, 1000)
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
    }

    fun isSpeaking(): Boolean {
        return tts?.isSpeaking ?: false
    }
}
TTS

echo "✅ TTS PROFESSIONNEL CONFIGURÉ!"
echo "📊 Logique de détection:"
echo "   - ✅ Vérifie les langues disponibles TTS"
echo "   - ✅ Essaie la langue système exacte"
echo "   - ✅ Essaie la langue de base (sans pays)"
echo "   - ✅ Fallback anglais"
echo "   - ✅ Fallback première langue disponible"
echo "   - ✅ Logs détaillés pour debug"
echo ""
echo "🚀 Cette version utilise VRAIMENT la détection système!"
