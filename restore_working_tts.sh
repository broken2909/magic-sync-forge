#!/bin/bash
echo "🔧 RESTAURATION TTS FONCTIONNEL + AMÉLIORATIONS STABLES"

# 1. Restaurer l'ancienne logique TTS avec délai
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
                    Log.e(TAG, "Erreur initialisation TTS: \$status")
                }
            }
        }
    }

    private fun setupTTSWithSystemLanguage() {
        val systemLocale = Locale.getDefault()
        
        // Vérifier les langues disponibles dans TTS
        val availableLanguages = tts?.availableLanguages ?: emptySet()
        Log.d(TAG, "Langues disponibles TTS: \$availableLanguages")
        Log.d(TAG, "Langue système: \$systemLocale")
        
        // Essayer la langue système exacte
        if (availableLanguages.contains(systemLocale)) {
            tts?.language = systemLocale
            Log.d(TAG, "Langue système configurée: \$systemLocale")
        }
        // Sinon essayer la langue de base (sans pays)
        else if (availableLanguages.contains(Locale(systemLocale.language))) {
            tts?.language = Locale(systemLocale.language)
            Log.d(TAG, "Langue de base configurée: \${systemLocale.language}")
        }
        // Sinon utiliser l'anglais comme fallback
        else if (availableLanguages.contains(Locale.ENGLISH)) {
            tts?.language = Locale.ENGLISH
            Log.d(TAG, "Fallback anglais configuré")
        }
        // Sinon utiliser la première langue disponible
        else if (availableLanguages.isNotEmpty()) {
            tts?.language = availableLanguages.first()
            Log.d(TAG, "Première langue disponible configurée: \${availableLanguages.first()}")
        }
        
        // Configuration de base
        tts?.setSpeechRate(1.0f)
        tts?.setPitch(1.0f)
        
        tts?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
            override fun onStart(utteranceId: String?) {
                Log.d(TAG, "TTS started: \$utteranceId")
            }
            override fun onDone(utteranceId: String?) {
                Log.d(TAG, "TTS completed: \$utteranceId")
            }
            override fun onError(utteranceId: String?) {
                Log.e(TAG, "TTS error: \$utteranceId")
            }
        })
        
        Log.d(TAG, "TTS final - Langue: \${tts?.language}, Pays: \${tts?.language?.country}")
    }

    fun speak(context: Context, text: String) {
        if (!PreferencesManager.isVoiceFeedbackEnabled(context)) {
            return
        }
        
        if (!isInitialized) {
            initialize(context)
            // DÉLAI CRITIQUE - Attendre que TTS s'initialise
            android.os.Handler().postDelayed({
                doSpeak(text)
            }, 1000)
        } else {
            doSpeak(text)
        }
    }

    private fun doSpeak(text: String) {
        if (isInitialized && tts != null) {
            Log.d(TAG, "Speaking: \$text (langue: \${tts?.language})")
            tts?.speak(text, TextToSpeech.QUEUE_ADD, null, "tts_utterance")
        } else {
            Log.w(TAG, "TTS non initialisé pour: \$text")
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

# 2. Corriger FirstLaunchWelcome pour utiliser la traduction
sed -i 's/val message = "Bienvenue dans votre assistant vocal MagicControl"/val message = context.getString(R.string.welcome_message)/' app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt

echo ""
echo "✅ RESTAURATION TERMINÉE :"
echo "• Ancienne logique TTS avec délai de 1000ms RESTAURÉE"
echo "• FirstLaunchWelcome utilise MAINTENANT R.string.welcome_message"
echo "• Structure XML et manifest propres GARDÉES"

echo ""
echo "🔍 VÉRIFICATIONS :"
echo "Délai TTS restauré :"
grep -n "postDelayed" app/src/main/java/com/magiccontrol/tts/TTSManager.kt
echo ""
echo "Traduction activée :"
grep -n "getString" app/src/main/java/com/magiccontrol/utils/FirstLaunchWelcome.kt
