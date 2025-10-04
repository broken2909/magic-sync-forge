package com.magiccontrol.utils

import android.content.Context
import android.content.SharedPreferences
import java.util.Locale

object PreferencesManager {

    private fun getPreferences(context: Context): SharedPreferences {
        return context.getSharedPreferences("magic_control_prefs", Context.MODE_PRIVATE)
    }

    // === GESTION PREMIER LANCEMENT ===
    fun isFirstLaunch(context: Context): Boolean {
        return getPreferences(context).getBoolean("first_launch", true)
    }

    fun setFirstLaunchComplete(context: Context) {
        getPreferences(context).edit().putBoolean("first_launch", false).apply()
    }

    // === GESTION LANGUE ===
    fun getCurrentLanguage(context: Context): String {
        val savedLanguage = getPreferences(context).getString("current_language", null)
        return savedLanguage ?: getSystemLanguage()
    }

    fun setCurrentLanguage(context: Context, language: String) {
        getPreferences(context).edit().putString("current_language", language).apply()
    }

    private fun getSystemLanguage(): String {
        val systemLang = Locale.getDefault().language
        return when {
            systemLang == "fr" -> "fr"
            systemLang == "en" -> "en"
            systemLang.startsWith("fr") -> "fr"
            systemLang.startsWith("en") -> "en"
            else -> "en"
        }
    }

    // === MOT D'ACTIVATION ===
    fun getActivationKeyword(context: Context): String {
        return getPreferences(context).getString("activation_keyword", "magic") ?: "magic"
    }

    fun setActivationKeyword(context: Context, keyword: String) {
        getPreferences(context).edit().putString("activation_keyword", keyword).apply()
    }

    // === FEEDBACK VOCAL ===
    fun isVoiceFeedbackEnabled(context: Context): Boolean {
        return getPreferences(context).getBoolean("voice_feedback", true)
    }

    fun setVoiceFeedbackEnabled(context: Context, enabled: Boolean) {
        getPreferences(context).edit().putBoolean("voice_feedback", enabled).apply()
    }

    // === VITESSE VOCALE ===
    fun getVoiceSpeed(context: Context): Int {
        return getPreferences(context).getInt("voice_speed", 80)
    }

    fun setVoiceSpeed(context: Context, speed: Int) {
        getPreferences(context).edit().putInt("voice_speed", speed).apply()
    }

    // === MÉTHODES POUR EXTRACTION MODÈLES ===
    fun getBoolean(context: Context, key: String, defaultValue: Boolean): Boolean {
        return getPreferences(context).getBoolean(key, defaultValue)
    }

    fun setBoolean(context: Context, key: String, value: Boolean) {
        getPreferences(context).edit().putBoolean(key, value).apply()
    }

    // === MÉTHODES FUTURES ===
    fun getWelcomeMessageEnabled(context: Context): Boolean {
        return getPreferences(context).getBoolean("welcome_message_enabled", true)
    }

    fun setWelcomeMessageEnabled(context: Context, enabled: Boolean) {
        getPreferences(context).edit().putBoolean("welcome_message_enabled", enabled).apply()
    }
}
