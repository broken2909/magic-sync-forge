package com.magiccontrol.utils

object KeywordUtils {
    fun containsWakeWord(text: String, wakeWord: String = "magic"): Boolean {
        return text.contains(wakeWord, ignoreCase = true)
    }
}
