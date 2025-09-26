package com.magiccontrol.utils

import android.content.Context

object KeywordUtils {
   
    /**
     * Vérifie si l'audio contient le mot-clé d'activation
     * Supporte tous les mots-clés définis dans les préférences
     */
    fun containsActivationKeyword(context: Context, audioData: String): Boolean {
        val keyword = PreferencesManager.getActivationKeyword(context)
        return audioData.contains(keyword, ignoreCase = true)
    }

    /**
     * Liste des mots-clés supportés (pour référence)
     */
    fun getSupportedKeywords(): List<String> {
        return listOf("magic", "okay", "dis", "écoute", "hey", "alexa", "google")
    }

    /**
     * Validation d'un nouveau mot-clé
     */
    fun isValidKeyword(keyword: String): Boolean {
        return keyword.length in 2..20 && keyword.matches(Regex("[a-zA-ZÀ-ÿ]+"))
    }
}