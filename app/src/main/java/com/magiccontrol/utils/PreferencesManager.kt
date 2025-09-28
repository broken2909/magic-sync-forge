package com.magiccontrol.utils

import android.content.Context
import android.content.SharedPreferences

object PreferencesManager {

    private fun getPreferences(context: Context): SharedPreferences {
        return context.getSharedPreferences("magic_control_prefs", Context.MODE_PRIVATE)
    }

    // Activation keyword
    fun getActivationKeyword(context: Context): String {
        return getPreferences(context).getString("activation_keyword", "magic") ?: "magic"
    }

    fun setActivationKeyword(context: Context, keyword: String) {
        getPreferences(context).edit().putString("activation_keyword", keyword).apply()
    }

    // Current language
    fun getCurrentLanguage(context: Context): String {
        return getPreferences(context).getString("current_language", "fr") ?: "fr"
    }

    fun setCurrentLanguage(context: Context, language: String) {
        getPreferences(context).edit().putString("current_language", language).apply()
    }

    // Voice feedback
    fun isVoiceFeedbackEnabled(context: Context): Boolean {
        return getPreferences(context).getBoolean("voice_feedback_enabled", true)
    }

    fun setVoiceFeedbackEnabled(context: Context, enabled: Boolean) {
        getPreferences(context).edit().putBoolean("voice_feedback_enabled", enabled).apply()
    }

    // Voice speed
    fun getVoiceSpeed(context: Context): Int {
        return getPreferences(context).getInt("voice_speed", 100)
    }

    fun setVoiceSpeed(context: Context, speed: Int) {
        getPreferences(context).edit().putInt("voice_speed", speed).apply()
    }

    // First launch
    fun isFirstLaunch(context: Context): Boolean {
        return getPreferences(context).getBoolean("first_launch", true)
    }

    fun setFirstLaunch(context: Context, isFirst: Boolean) {
        getPreferences(context).edit().putBoolean("first_launch", isFirst).apply()
    }
}
