package com.magiccontrol.utils

import android.content.Context
import android.content.SharedPreferences

object PreferencesManager {
    
    private const val PREFS_NAME = "magic_control_prefs"
    
    fun getActivationKeyword(context: Context): String {
        return getPreferences(context).getString("activation_keyword", "magic") ?: "magic"
    }
    
    fun setActivationKeyword(context: Context, keyword: String) {
        getPreferences(context).edit().putString("activation_keyword", keyword).apply()
    }
    
    private fun getPreferences(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }
}
