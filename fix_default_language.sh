#!/bin/bash
echo "🔧 CORRECTION LANGUE PAR DÉFAUT - FR & EN"

# Créer la version corrigée de PreferencesManager
cat > app/src/main/java/com/magiccontrol/utils/PreferencesManager.kt << 'FIX'
package com.magiccontrol.utils

import android.content.Context
import android.content.SharedPreferences
import java.util.Locale

object PreferencesManager {

    private fun getPreferences(context: Context): SharedPreferences {
        return context.getSharedPreferences("magic_control_prefs", Context.MODE_PRIVATE)
    }

    // Current language - CORRECTION: détection automatique + fallback fr/en
    fun getCurrentLanguage(context: Context): String {
        val savedLanguage = getPreferences(context).getString("current_language", null)
        return savedLanguage ?: getSystemLanguage()
    }

    fun setCurrentLanguage(context: Context, language: String) {
        getPreferences(context).edit().putString("current_language", language).apply()
    }

    // CORRECTION: Détection langue système avec fallback fr/en
    private fun getSystemLanguage(): String {
        val systemLang = Locale.getDefault().language
        return when {
            systemLang == "fr" -> "fr"
            systemLang == "en" -> "en"
            systemLang.startsWith("fr") -> "fr"  // fr_CA, fr_BE, etc.
            systemLang.startsWith("en") -> "en"  // en_US, en_GB, etc.
            else -> "en"  // Fallback sur anglais pour autres langues
        }
    }

    // Activation keyword
    fun getActivationKeyword(context: Context): String {
        return getPreferences(context).getString("activation_keyword", "magic") ?: "magic"
    }

    fun setActivationKeyword(context: Context, keyword: String) {
        getPreferences(context).edit().putString("activation_keyword", keyword).apply()
    }

    // Voice feedback
    fun isVoiceFeedbackEnabled(context: Context): Boolean {
        return getPreferences(context).getBoolean("voice_feedback", true)
    }

    fun setVoiceFeedbackEnabled(context: Context, enabled: Boolean) {
        getPreferences(context).edit().putBoolean("voice_feedback", enabled).apply()
    }

    // Voice speed
    fun getVoiceSpeed(context: Context): Int {
        return getPreferences(context).getInt("voice_speed", 100)
    }

    fun setVoiceSpeed(context: Context, speed: Int) {
        getPreferences(context).edit().putInt("voice_speed", speed).apply()
    }
}
FIX

echo ""
echo "✅ CORRECTION APPLIQUÉE"
echo "📊 Langue par défaut: détection système + fallback fr/en"
echo "📊 Système français → 'fr', Autres langues → 'en'"
echo ""
echo "🔍 VÉRIFICATION:"
grep -A 10 "getSystemLanguage" app/src/main/java/com/magiccontrol/utils/PreferencesManager.kt
