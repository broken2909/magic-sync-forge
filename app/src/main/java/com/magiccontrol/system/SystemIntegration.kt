package com.magiccontrol.system

import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.net.wifi.WifiManager
import android.provider.Settings
import android.util.Log
import com.magiccontrol.tts.TTSManager

object SystemIntegration {
    private val TAG = "SystemIntegration"

    fun handleSystemCommand(context: Context, command: String) {
        Log.d(TAG, "Traitement de la commande: $command")
        
        when {
            command.contains("volume", ignoreCase = true) -> 
                handleVolumeCommand(context, command)
            command.contains("wifi", ignoreCase = true) -> 
                toggleWifi(context)
            command.contains("bluetooth", ignoreCase = true) -> 
                toggleBluetooth(context)
            command.contains("luminosité", ignoreCase = true) -> 
                adjustBrightness(context, command)
            command.contains("paramètres", ignoreCase = true) -> 
                openSettings(context)
            command.contains("accueil", ignoreCase = true) -> 
                goHome(context)
            command.contains("retour", ignoreCase = true) -> 
                goBack(context)
            else -> 
                TTSManager.speak(context, "Commande non reconnue")
        }
    }

    private fun handleVolumeCommand(context: Context, command: String) {
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        
        when {
            command.contains("augmenter", ignoreCase = true) -> {
                audioManager.adjustVolume(AudioManager.ADJUST_RAISE, AudioManager.FLAG_SHOW_UI)
                TTSManager.speak(context, "Volume augmenté")
            }
            command.contains("baisser", ignoreCase = true) -> {
                audioManager.adjustVolume(AudioManager.ADJUST_LOWER, AudioManager.FLAG_SHOW_UI)
                TTSManager.speak(context, "Volume baissé")
            }
            command.contains("silence", ignoreCase = true) -> {
                audioManager.adjustVolume(AudioManager.ADJUST_MUTE, AudioManager.FLAG_SHOW_UI)
                TTSManager.speak(context, "Mode silence activé")
            }
        }
    }

    private fun toggleWifi(context: Context) {
        try {
            val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            val isEnabled = wifiManager.isWifiEnabled
            wifiManager.isWifiEnabled = !isEnabled
            
            val status = if (!isEnabled) "activé" else "désactivé"
            TTSManager.speak(context, "Wifi $status")
        } catch (e: SecurityException) {
            Log.e(TAG, "Permission WIFI non accordée", e)
            TTSManager.speak(context, "Permission Wifi manquante")
        }
    }

    private fun toggleBluetooth(context: Context) {
        TTSManager.speak(context, "Commande Bluetooth non encore implémentée")
    }

    private fun adjustBrightness(context: Context, command: String) {
        TTSManager.speak(context, "Commande luminosité non encore implémentée")
    }

    private fun openSettings(context: Context) {
        try {
            val intent = Intent(Settings.ACTION_SETTINGS)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            TTSManager.speak(context, "Paramètres ouverts")
        } catch (e: Exception) {
            Log.e(TAG, "Erreur ouverture paramètres", e)
        }
    }

    private fun goHome(context: Context) {
        try {
            val intent = Intent(Intent.ACTION_MAIN)
            intent.addCategory(Intent.CATEGORY_HOME)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            TTSManager.speak(context, "Écran d'accueil")
        } catch (e: Exception) {
            Log.e(TAG, "Erreur retour accueil", e)
        }
    }

    private fun goBack(context: Context) {
        TTSManager.speak(context, "Commande retour non encore implémentée")
    }
}
