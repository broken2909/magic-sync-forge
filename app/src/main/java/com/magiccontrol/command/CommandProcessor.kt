package com.magiccontrol.command

import android.content.Context
import android.util.Log
import com.magiccontrol.system.SystemIntegration

class CommandProcessor(private val context: Context) {
    
    private val TAG = "CommandProcessor"
    
    fun processCommand(command: String, callback: (Boolean) -> Unit) {
        try {
            Log.d(TAG, "Traitement commande: '$command'")
            
            // Normalize command
            val normalizedCommand = command.lowercase().trim()
            
            // Check if command is recognized
            val isRecognized = isCommandRecognized(normalizedCommand)
            
            if (isRecognized) {
                // Execute command via SystemIntegration
                SystemIntegration.handleSystemCommand(context, normalizedCommand)
                callback(true)
            } else {
                Log.w(TAG, "Commande non reconnue: '$command'")
                callback(false)
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Erreur traitement commande", e)
            callback(false)
        }
    }
    
    private fun isCommandRecognized(command: String): Boolean {
        val recognizedCommands = listOf(
            // Navigation
            "retour", "accueil", "précédent",
            "back", "home", "previous",
            
            // Applications
            "ouvrir", "lancer", "fermer",
            "open", "launch", "close",
            
            // Système
            "volume", "luminosité", "wifi", "bluetooth",
            "brightness", "settings", "paramètres",
            
            // Test commands
            "test", "bonjour", "hello"
        )
        
        return recognizedCommands.any { command.contains(it) }
    }
}