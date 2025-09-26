package com.magiccontrol.utils

import android.content.Context
import android.content.SharedPreferences

object PreferencesManager {
    private const val PREFS_NAME = "magic_control_prefs"

    private fun getPreferences(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    fun getActivationKeyword(context: Context): String {
        return getPreferences(context).getString("activation_keyword", "magic") ?: "magic"
    }

    fun setActivationKeyword(context: Context, keyword: String) {
        getPreferences(context).edit().putString("activation_keyword", keyword).apply()
    }

    fun isVoiceFeedbackEnabled(context: Context): Boolean {
        return getPreferences(context).getBoolean("voice_feedback", true)
    }

    fun setVoiceFeedbackEnabled(context: Context, enabled: Boolean) {
        getPreferences(context).edit().putBoolean("voice_feedback", enabled).apply()
    }

    fun getCurrentLanguage(context: Context): String {
        return getPreferences(context).getString("language", "fr") ?: "fr"
    }

    fun setCurrentLanguage(context: Context, language: String) {
        getPreferences(context).edit().putString("language", language).apply()
    }

    fun getVoiceSpeed(context: Context): Int {
        return getPreferences(context).getInt("voice_speed", 100)
    }

    fun setVoiceSpeed(context: Context, speed: Int) {
        getPreferences(context).edit().putInt("voice_speed", speed).apply()
    }
}