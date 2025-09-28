package com.magiccontrol.utils

import android.content.Context

object PreferencesManager {
    private const val PREFS_NAME = "magic_control_prefs"
   
    fun getActivationKeyword(context: Context): String {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getString("activation_keyword", "magic") ?: "magic"
    }
   
    fun setActivationKeyword(context: Context, keyword: String) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putString("activation_keyword", keyword).apply()
    }
   
    fun getMicrophoneSensitivity(context: Context): Int {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getInt("microphone_sensitivity", 50)
    }
   
    fun setMicrophoneSensitivity(context: Context, sensitivity: Int) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putInt("microphone_sensitivity", sensitivity).apply()
    }
   
    fun isPasswordLockEnabled(context: Context): Boolean {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getBoolean("password_lock", false)
    }
   
    fun setPasswordLockEnabled(context: Context, enabled: Boolean) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putBoolean("password_lock", enabled).apply()
    }
   
    fun getSavedPassword(context: Context): String? {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getString("saved_password", null)
    }
   
    fun savePassword(context: Context, password: String) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putString("saved_password", password).apply()
    }
   
    fun getInstalledLanguages(context: Context): Set<String> {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getStringSet("installed_languages", setOf("fr", "en")) ?: setOf("fr", "en")
    }
   
    fun addInstalledLanguage(context: Context, language: String) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val currentLanguages = getInstalledLanguages(context).toMutableSet()
        currentLanguages.add(language)
        prefs.edit().putStringSet("installed_languages", currentLanguages).apply()
    }
   
    fun removeInstalledLanguage(context: Context, language: String) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val currentLanguages = getInstalledLanguages(context).toMutableSet()
        currentLanguages.remove(language)
        prefs.edit().putStringSet("installed_languages", currentLanguages).apply()
    }
}
