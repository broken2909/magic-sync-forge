package com.magiccontrol.tts

import android.content.Context
import android.speech.tts.TextToSpeech
import com.magiccontrol.utils.PreferencesManager
import java.util.Locale

class TTSManager(private val context: Context) : TextToSpeech.OnInitListener {
    private var tts: TextToSpeech? = null
   
    init {
        tts = TextToSpeech(context, this)
    }
   
    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            val lang = when (getCurrentLanguage()) {
                "fr" -> Locale.FRENCH
                "en" -> Locale.ENGLISH
                else -> Locale.FRENCH
            }
            tts?.language = lang
        }
    }
   
    fun speak(text: String) {
        tts?.speak(text, TextToSpeech.QUEUE_ADD, null, null)
    }
   
    fun stop() {
        tts?.stop()
    }
   
    fun shutdown() {
        tts?.shutdown()
    }
    
    private fun getCurrentLanguage(): String {
        // Utiliser la langue depuis les préférences
        val installedLanguages = PreferencesManager.getInstalledLanguages(context)
        return installedLanguages.firstOrNull() ?: "fr"
    }
}
