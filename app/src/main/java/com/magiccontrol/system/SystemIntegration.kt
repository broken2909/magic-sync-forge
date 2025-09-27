package com.magiccontrol.system

import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.net.wifi.WifiManager
import android.provider.Settings
import android.util.Log
import com.magiccontrol.tts.TTSManager
import com.magiccontrol.utils.PreferencesManager

object SystemIntegration {
    private val TAG = "SystemIntegration"
    private var findPhoneMediaPlayer: MediaPlayer? = null
    private var isFindingPhone = false

    fun handleSystemCommand(context: Context, command: String) {
        Log.d(TAG, "Traitement de la commande: $command")
        
        when {
            command.contains("volume", ignoreCase = true) ->
                handleVolumeCommand(context, command)
            command.contains("wifi", ignoreCase = true) ->
                toggleWifi(context)
            command.contains("bluetooth", ignoreCase = true) ->
                toggleBluetooth(context)
            command.contains("luminosité", ignoreCase = true) || command.contains("brightness", ignoreCase = true) ->
                adjustBrightness(context, command)
            command.contains("paramètres", ignoreCase = true) || command.contains("settings", ignoreCase = true) ->
                openSettings(context)
            command.contains("accueil", ignoreCase = true) || command.contains("home", ignoreCase = true) ->
                goHome(context)
            command.contains("retour", ignoreCase = true) || command.contains("back", ignoreCase = true) ->
                goBack(context)
            command.contains("tu es où", ignoreCase = true) || 
            command.contains("trouve", ignoreCase = true) ||
            command.contains("where are you", ignoreCase = true) ||
            command.contains("find", ignoreCase = true) ->
                startFindPhoneFeature(context)
            command.contains("stop", ignoreCase = true) || 
            command.contains("arrête", ignoreCase = true) ->
                stopFindPhoneFeature(context)
            else ->
                TTSManager(context).speak(getLocalizedMessage(context, "command_not_recognized"))
        }
    }

    // FONCTION "TROUVER LE TÉLÉPHONE ÉGARÉ" - MULTILINGUE
    fun startFindPhoneFeature(context: Context) {
        if (isFindingPhone) return
        
        isFindingPhone = true
        val keyword = PreferencesManager.getActivationKeyword(context)
        
        val message = getLocalizedMessage(context, "find_phone_activated").replace("{keyword}", keyword)
        TTSManager(context).speak(message)
        
        try {
            val soundUri = Uri.parse("android.resource://com.magiccontrol/raw/welcome_sound")
            findPhoneMediaPlayer = MediaPlayer.create(context, soundUri)
            findPhoneMediaPlayer?.isLooping = true
            findPhoneMediaPlayer?.setOnCompletionListener { 
                findPhoneMediaPlayer?.start()
            }
            findPhoneMediaPlayer?.start()
        } catch (e: Exception) {
            Log.e(TAG, "Erreur lecture son recherche téléphone", e)
            TTSManager(context).speak(getLocalizedMessage(context, "sound_error"))
            isFindingPhone = false
        }
    }

    fun stopFindPhoneFeature(context: Context) {
        if (!isFindingPhone) return
        
        isFindingPhone = false
        findPhoneMediaPlayer?.stop()
        findPhoneMediaPlayer?.release()
        findPhoneMediaPlayer = null
        
        TTSManager(context).speak(getLocalizedMessage(context, "sound_stopped"))
    }

    // SYSTÈME DE LOCALISATION MULTILINGUE
    private fun getSystemLanguage(context: Context): String {
        val installedLanguages = PreferencesManager.getInstalledLanguages(context)
        val systemLang = java.util.Locale.getDefault().language
        
        return if (installedLanguages.contains(systemLang)) {
            systemLang
        } else {
            installedLanguages.firstOrNull() ?: "en"
        }
    }

    private fun getLocalizedMessage(context: Context, messageKey: String): String {
        return when (getSystemLanguage(context)) {
            "fr" -> when (messageKey) {
                "find_phone_activated" -> "Je suis ici ! Dites {keyword} stop pour arrêter le son."
                "sound_stopped" -> "Son arrêté"
                "volume_increased" -> "Volume augmenté"
                "volume_decreased" -> "Volume baissé"
                "silence_activated" -> "Mode silence activé"
                "wifi_activated" -> "Wifi activé"
                "wifi_deactivated" -> "Wifi désactivé"
                "wifi_permission_missing" -> "Permission Wifi manquante"
                "bluetooth_not_implemented" -> "Commande Bluetooth non encore implémentée"
                "brightness_not_implemented" -> "Commande luminosité non encore implémentée"
                "settings_opened" -> "Paramètres ouverts"
                "home_screen" -> "Écran d'accueil"
                "back_not_implemented" -> "Commande retour non encore implémentée"
                "command_not_recognized" -> "Commande non reconnue"
                "sound_error" -> "Erreur de son"
                else -> "Message non traduit"
            }
            "zh" -> when (messageKey) {
                "find_phone_activated" -> "我在这里！说 {keyword} stop 停止声音。"
                "sound_stopped" -> "声音已停止"
                "volume_increased" -> "音量增加"
                "volume_decreased" -> "音量减少"
                "silence_activated" -> "静音模式已激活"
                else -> getLocalizedMessage(context, messageKey)
            }
            else -> when (messageKey) {
                "find_phone_activated" -> "I'm here! Say {keyword} stop to turn off the sound."
                "sound_stopped" -> "Sound stopped"
                "volume_increased" -> "Volume increased"
                "volume_decreased" -> "Volume decreased"
                "silence_activated" -> "Silence mode activated"
                "wifi_activated" -> "Wifi activated"
                "wifi_deactivated" -> "Wifi deactivated"
                "wifi_permission_missing" -> "Missing Wifi permission"
                "bluetooth_not_implemented" -> "Bluetooth command not yet implemented"
                "brightness_not_implemented" -> "Brightness command not yet implemented"
                "settings_opened" -> "Settings opened"
                "home_screen" -> "Home screen"
                "back_not_implemented" -> "Back command not yet implemented"
                "command_not_recognized" -> "Command not recognized"
                "sound_error" -> "Sound error"
                else -> "Message not translated"
            }
        }
    }

    // FONCTIONS SYSTÈME AVEC LOCALISATION
    private fun handleVolumeCommand(context: Context, command: String) {
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        
        when {
            command.contains("augmenter", ignoreCase = true) || command.contains("increase", ignoreCase = true) -> {
                audioManager.adjustVolume(AudioManager.ADJUST_RAISE, AudioManager.FLAG_SHOW_UI)
                TTSManager(context).speak(getLocalizedMessage(context, "volume_increased"))
            }
            command.contains("baisser", ignoreCase = true) || command.contains("decrease", ignoreCase = true) -> {
                audioManager.adjustVolume(AudioManager.ADJUST_LOWER, AudioManager.FLAG_SHOW_UI)
                TTSManager(context).speak(getLocalizedMessage(context, "volume_decreased"))
            }
            command.contains("silence", ignoreCase = true) || command.contains("mute", ignoreCase = true) -> {
                audioManager.adjustVolume(AudioManager.ADJUST_MUTE, AudioManager.FLAG_SHOW_UI)
                TTSManager(context).speak(getLocalizedMessage(context, "silence_activated"))
            }
        }
    }

    private fun toggleWifi(context: Context) {
        try {
            val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            val isEnabled = wifiManager.isWifiEnabled
            wifiManager.isWifiEnabled = !isEnabled
            
            val messageKey = if (!isEnabled) "wifi_activated" else "wifi_deactivated"
            TTSManager(context).speak(getLocalizedMessage(context, messageKey))
        } catch (e: SecurityException) {
            Log.e(TAG, "Permission WIFI non accordée", e)
            TTSManager(context).speak(getLocalizedMessage(context, "wifi_permission_missing"))
        }
    }

    private fun toggleBluetooth(context: Context) {
        TTSManager(context).speak(getLocalizedMessage(context, "bluetooth_not_implemented"))
    }

    private fun adjustBrightness(context: Context, command: String) {
        TTSManager(context).speak(getLocalizedMessage(context, "brightness_not_implemented"))
    }

    private fun openSettings(context: Context) {
        try {
            val intent = Intent(Settings.ACTION_SETTINGS)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            TTSManager(context).speak(getLocalizedMessage(context, "settings_opened"))
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
            TTSManager(context).speak(getLocalizedMessage(context, "home_screen"))
        } catch (e: Exception) {
            Log.e(TAG, "Erreur retour accueil", e)
        }
    }

    private fun goBack(context: Context) {
        TTSManager(context).speak(getLocalizedMessage(context, "back_not_implemented"))
    }
}
