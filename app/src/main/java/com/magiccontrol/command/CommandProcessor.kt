package com.magiccontrol.command

import android.content.Context
import com.magiccontrol.system.SystemIntegration
import com.magiccontrol.tts.TTSManager

object CommandProcessor {
    
    fun execute(context: Context, command: String) {
        when {
            command.contains("volume") -> SystemIntegration.handleSystemCommand(context, command)
            command.contains("wifi") -> SystemIntegration.handleSystemCommand(context, command)
            command.contains("accueil") -> SystemIntegration.handleSystemCommand(context, command)
            command.contains("retour") -> SystemIntegration.handleSystemCommand(context, command)
            else -> TTSManager.speak("Commande exécutée: $command")
        }
    }
}
