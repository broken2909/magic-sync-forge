package com.magiccontrol.utils

import android.content.Context
import android.content.SharedPreferences
import java.util.Locale

object WelcomeManager {
    private const val PREFS_WELCOME = "welcome_prefs"
    private const val KEY_WELCOME_SHOWN = "welcome_shown"

    fun shouldShowWelcome(context: Context): Boolean {
        val prefs = context.getSharedPreferences(PREFS_WELCOME, Context.MODE_PRIVATE)
        return !prefs.getBoolean(KEY_WELCOME_SHOWN, false)
    }

    fun markWelcomeShown(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_WELCOME, Context.MODE_PRIVATE)
        prefs.edit().putBoolean(KEY_WELCOME_SHOWN, true).apply()
    }

    fun getWelcomeMessage(context: Context): String {
        val currentLocale = Locale.getDefault().language
        return when (currentLocale) {
            "fr" -> "Bienvenue dans votre assistant vocal MagicControl"
            "en" -> "Welcome to your MagicControl voice assistant"
            "zh" -> "欢迎使用您的 MagicControl 语音助手"
            "es" -> "Bienvenido a su asistente de voz MagicControl"
            "ar" -> "مرحبًا بك في مساعدك الصوتي MagicControl"
            else -> "Welcome to your MagicControl voice assistant"
        }
    }
}
