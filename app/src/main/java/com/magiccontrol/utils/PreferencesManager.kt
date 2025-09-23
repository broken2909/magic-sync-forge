package com.magiccontrol.utils

import android.content.Context
import android.content.SharedPreferences
import android.speech.tts.TextToSpeech

object PreferencesManager {
    private const val PREFS_NAME = "magic_control_prefs"
    
    // Mot d'éveil
    fun getWakeWord(context: Context): String {
        return getPreferences(context).getString("wake_word", "magic") ?: "magic"
    }
    
    fun setWakeWord(context: Context, word: String) {
        getPreferences(context).edit().putString("wake_word", word).apply()
    }
    
    // Langue de reconnaissance
    fun getLanguage(context: Context): String {
        return getPreferences(context).getString("language", "fr") ?: "fr"
    }
    
    fun setLanguage(context: Context, language: String) {
        getPreferences(context).edit().putString("language", language).apply()
    }
    
    // Utiliser les langues système TTS
    fun useSystemTtsLanguages(context: Context): Boolean {
        return getPreferences(context).getBoolean("use_system_tts", true)
    }
    
    fun setUseSystemTtsLanguages(context: Context, useSystem: Boolean) {
        getPreferences(context).edit().putBoolean("use_system_tts", useSystem).apply()
    }
    
    // Langue TTS spécifique
    fun getTtsLanguage(context: Context): String {
        return getPreferences(context).getString("tts_language", "") ?: ""
    }
    
    fun setTtsLanguage(context: Context, language: String) {
        getPreferences(context).edit().putString("tts_language", language).apply()
    }
    
    // Sensibilité micro
    fun getMicrophoneSensitivity(context: Context): Int {
        return getPreferences(context).getInt("micro_sensitivity", 75)
    }
    
    fun setMicrophoneSensitivity(context: Context, sensitivity: Int) {
        getPreferences(context).edit().putInt("micro_sensitivity", sensitivity).apply()
    }
    
    // Volume TTS
    fun getTtsVolume(context: Context): Int {
        return getPreferences(context).getInt("tts_volume", 80)
    }
    
    fun setTtsVolume(context: Context, volume: Int) {
        getPreferences(context).edit().putInt("tts_volume", volume).apply()
    }
    
    // Commandes système
    fun isVolumeControlEnabled(context: Context): Boolean {
        return getPreferences(context).getBoolean("volume_control", true)
    }
    
    fun setVolumeControlEnabled(context: Context, enabled: Boolean) {
        getPreferences(context).edit().putBoolean("volume_control", enabled).apply()
    }
    
    fun isWifiControlEnabled(context: Context): Boolean {
        return getPreferences(context).getBoolean("wifi_control", true)
    }
    
    fun setWifiControlEnabled(context: Context, enabled: Boolean) {
        getPreferences(context).edit().putBoolean("wifi_control", enabled).apply()
    }
    
    fun isNavigationControlEnabled(context: Context): Boolean {
        return getPreferences(context).getBoolean("navigation_control", true)
    }
    
    fun setNavigationControlEnabled(context: Context, enabled: Boolean) {
        getPreferences(context).edit().putBoolean("navigation_control", enabled).apply()
    }
    
    // Sécurité - Confirmation vocale
    fun isVoiceConfirmationEnabled(context: Context): Boolean {
        return getPreferences(context).getBoolean("voice_confirmation", true)
    }
    
    fun setVoiceConfirmationEnabled(context: Context, enabled: Boolean) {
        getPreferences(context).edit().putBoolean("voice_confirmation", enabled).apply()
    }
    
    // Sécurité - Délai de confirmation
    fun getConfirmationDelay(context: Context): Int {
        return getPreferences(context).getInt("confirmation_delay", 3)
    }
    
    fun setConfirmationDelay(context: Context, delay: Int) {
        getPreferences(context).edit().putInt("confirmation_delay", delay).apply()
    }
    
    // Accessibilité - Feedback haptique
    fun isHapticFeedbackEnabled(context: Context): Boolean {
        return getPreferences(context).getBoolean("haptic_feedback", true)
    }
    
    fun setHapticFeedbackEnabled(context: Context, enabled: Boolean) {
        getPreferences(context).edit().putBoolean("haptic_feedback", enabled).apply()
    }
    
    // Accessibilité - Audio stéréo
    fun isStereoAudioEnabled(context: Context): Boolean {
        return getPreferences(context).getBoolean("stereo_audio", false)
    }
    
    fun setStereoAudioEnabled(context: Context, enabled: Boolean) {
        getPreferences(context).edit().putBoolean("stereo_audio", enabled).apply()
    }
    
    private fun getPreferences(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }
}
