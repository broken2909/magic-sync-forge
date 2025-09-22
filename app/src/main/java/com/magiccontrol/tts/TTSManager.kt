package com.magiccontrol.tts

import android.content.Context
import android.speech.tts.TextToSpeech
import java.util.Locale

object TTSManager {
    
    private var tts: TextToSpeech? = null
    
    fun initialize(context: Context) {
        tts = TextToSpeech(context) { status ->
            if (status == TextToSpeech.SUCCESS) {
                tts?.language = Locale.FRENCH
            }
        }
    }
    
    fun speak(text: String) {
        tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, null)
    }
    
    fun shutdown() {
        tts?.shutdown()
    }
}
