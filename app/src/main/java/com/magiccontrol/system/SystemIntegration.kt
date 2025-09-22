package com.magiccontrol.system

import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.provider.Settings
import com.magiccontrol.tts.TTSManager

object SystemIntegration {
    
    fun handleSystemCommand(context: Context, command: String) {
        when {
            command.contains("volume") -> handleVolumeCommand(context, command)
            command.contains("wifi") -> toggleWifi(context)
            command.contains("accueil") -> goHome(context)
            command.contains("retour") -> goBack(context)
            command.contains("paramètres") -> openSettings(context)
            else -> TTSManager.speak("Commande système: $command")
        }
    }
    
    private fun handleVolumeCommand(context: Context, command: String) {
        val audioManager = context.getSystemService(AudioManager::class.java)
        when {
            command.contains("augmenter") -> {
                audioManager.adjustVolume(AudioManager.ADJUST_RAISE, AudioManager.FLAG_SHOW_UI)
                TTSManager.speak("Volume augmenté")
            }
            command.contains("baisser") -> {
                audioManager.adjustVolume(AudioManager.ADJUST_LOWER, AudioManager.FLAG_SHOW_UI)
                TTSManager.speak("Volume baissé")
            }
        }
    }
    
    private fun toggleWifi(context: Context) {
        TTSManager.speak("Wifi modifié")
    }
    
    private fun openSettings(context: Context) {
        val intent = Intent(Settings.ACTION_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
        TTSManager.speak("Paramètres ouverts")
    }
    
    private fun goHome(context: Context) {
        val intent = Intent(Intent.ACTION_MAIN)
        intent.addCategory(Intent.CATEGORY_HOME)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
        TTSManager.speak("Accueil")
    }
    
    private fun goBack(context: Context) {
        TTSManager.speak("Retour")
    }
}
