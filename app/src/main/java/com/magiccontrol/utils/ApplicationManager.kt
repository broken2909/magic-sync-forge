package com.magiccontrol.utils

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.util.Log

/**
 * Gestionnaire dynamique des applications installées
 */
class ApplicationManager(private val context: Context) {

    private val TAG = "ApplicationManager"
    
    // Applications système courantes avec leurs packages
    private val systemApps = mapOf(
        "appareil photo" to listOf(
            "com.android.camera2",
            "com.google.android.GoogleCamera", 
            "com.sec.android.app.camera"
        ),
        "galerie" to listOf(
            "com.android.gallery3d",
            "com.google.android.apps.photos",
            "com.sec.android.gallery3d"
        ),
        "navigateur" to listOf(
            "com.android.chrome",
            "com.sec.android.app.sbrowser",
            "org.mozilla.firefox"
        ),
        "paramètres" to listOf("com.android.settings"),
        "musique" to listOf(
            "com.sec.android.app.music",
            "com.android.music",
            "com.spotify.music"
        ),
        "messages" to listOf("com.android.mms"),
        "contacts" to listOf("com.android.contacts"),
        "téléphone" to listOf("com.android.dialer")
    )
    
    /**
     * Obtient la liste des applications installées avec leurs noms
     */
    fun getInstalledApps(): Map<String, String> {
        val apps = mutableMapOf<String, String>()
        
        try {
            val mainIntent = Intent(Intent.ACTION_MAIN, null)
            mainIntent.addCategory(Intent.CATEGORY_LAUNCHER)
            
            val packages = context.packageManager.queryIntentActivities(mainIntent, 0)
            
            for (info in packages) {
                val appName = info.loadLabel(context.packageManager).toString()
                val packageName = info.activityInfo.packageName
                apps[appName.lowercase()] = packageName
            }
            
            Log.d(TAG, "📱 ${apps.size} applications détectées")
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur scan applications", e)
        }
        
        return apps
    }
    
    /**
     * Ouvre une application par son nom
     */
    fun openApp(appName: String): Boolean {
        val normalizedName = appName.lowercase()
        val installedApps = getInstalledApps()
        
        Log.d(TAG, "🎯 Recherche application: '$normalizedName'")
        
        // 1. Recherche exacte dans les apps installées
        for ((name, packageName) in installedApps) {
            if (name.contains(normalizedName) || normalizedName.contains(name)) {
                Log.d(TAG, "✅ Application trouvée: $name -> $packageName")
                return launchApp(packageName)
            }
        }
        
        // 2. Recherche dans les apps système
        for ((systemName, packages) in systemApps) {
            if (normalizedName.contains(systemName) || systemName.contains(normalizedName)) {
                Log.d(TAG, "🔧 Application système: $systemName")
                for (packageName in packages) {
                    if (launchApp(packageName)) {
                        return true
                    }
                }
            }
        }
        
        Log.w(TAG, "❌ Application non trouvée: $appName")
        return false
    }
    
    /**
     * Lance une application par son package
     */
    private fun launchApp(packageName: String): Boolean {
        return try {
            val intent = context.packageManager.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                context.startActivity(intent)
                Log.d(TAG, "🚀 Application lancée: $packageName")
                true
            } else {
                Log.w(TAG, "❌ Intent null pour: $packageName")
                false
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur lancement application", e)
            false
        }
    }
    
    /**
     * Vérifie si une application est installée
     */
    fun isAppInstalled(appName: String): Boolean {
        val normalizedName = appName.lowercase()
        val installedApps = getInstalledApps()
        
        return installedApps.keys.any { it.contains(normalizedName) } ||
               systemApps.keys.any { normalizedName.contains(it) }
    }
    
    /**
     * Obtient les suggestions d'applications similaires
     */
    fun getAppSuggestions(input: String): List<String> {
        val suggestions = mutableListOf<String>()
        val installedApps = getInstalledApps()
        
        for (appName in installedApps.keys) {
            if (appName.contains(input.lowercase()) || input.lowercase().contains(appName)) {
                suggestions.add(appName)
            }
        }
        
        return suggestions.take(5) // Maximum 5 suggestions
    }
}
