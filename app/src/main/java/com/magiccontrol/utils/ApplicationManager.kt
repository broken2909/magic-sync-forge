package com.magiccontrol.utils

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.net.Uri
import android.provider.ContactsContract
import android.provider.MediaStore
import android.provider.Settings
import android.util.Log

class ApplicationManager(private val context: Context) {

    private val TAG = "ApplicationManager"

    private val systemApps = mapOf(
        "appareil photo" to listOf("com.android.camera2", "com.google.android.GoogleCamera", "com.sec.android.app.camera"),
        "galerie" to listOf("com.android.gallery3d", "com.google.android.apps.photos", "com.sec.android.gallery3d"),
        "navigateur" to listOf("com.android.chrome", "com.sec.android.app.sbrowser", "org.mozilla.firefox"),
        "paramètres" to listOf("com.android.settings"),
        "musique" to listOf("com.sec.android.app.music", "com.android.music", "com.spotify.music"),
        "messages" to listOf("com.android.mms"),
        "contacts" to listOf("com.android.contacts"),
        "téléphone" to listOf("com.android.dialer")
    )

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

    private fun launchIntent(intent: Intent): Boolean {
        return try {
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(intent)
            Log.d(TAG, "✅ Intent lancé: ${intent.action}")
            true
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur lancement intent", e)
            false
        }
    }

    fun openApp(appName: String): Boolean {
        Log.d(TAG, "📱 Tentative ouverture: $appName")
        val appIntents = mapOf(
            "appareil photo" to Intent(MediaStore.ACTION_IMAGE_CAPTURE),
            "caméra" to Intent(MediaStore.ACTION_IMAGE_CAPTURE),
            "galerie" to Intent(Intent.ACTION_VIEW, MediaStore.Images.Media.EXTERNAL_CONTENT_URI),
            "photos" to Intent(Intent.ACTION_VIEW, MediaStore.Images.Media.EXTERNAL_CONTENT_URI),
            "navigateur" to Intent(Intent.ACTION_VIEW, Uri.parse("https://google.com")),
            "internet" to Intent(Intent.ACTION_VIEW, Uri.parse("https://google.com")),
            "chrome" to Intent(Intent.ACTION_VIEW, Uri.parse("https://google.com")),
            "paramètres" to Intent(Settings.ACTION_SETTINGS),
            "settings" to Intent(Settings.ACTION_SETTINGS),
            "musique" to Intent(Intent.ACTION_VIEW, Uri.parse("content://media/external/audio/media")),
            "spotify" to Intent(Intent.ACTION_VIEW, Uri.parse("spotify:")),
            "messages" to Intent(Intent.ACTION_VIEW, Uri.parse("sms:")),
            "sms" to Intent(Intent.ACTION_VIEW, Uri.parse("sms:")),
            "contacts" to Intent(Intent.ACTION_VIEW, ContactsContract.Contacts.CONTENT_URI),
            "téléphone" to Intent(Intent.ACTION_DIAL),
            "appel" to Intent(Intent.ACTION_DIAL)
        )
        val normalizedName = appName.lowercase()
        for ((key, intent) in appIntents) {
            if (normalizedName.contains(key)) {
                Log.d(TAG, "✅ Intent trouvé: $key")
                return launchIntent(intent)
            }
        }
        Log.d(TAG, "🔍 Recherche dans apps installées: $appName")
        val installedApps = getInstalledApps()
        for ((name, packageName) in installedApps) {
            if (name.contains(normalizedName) || normalizedName.contains(name)) {
                Log.d(TAG, "✅ App trouvée: $name -> $packageName")
                return launchApp(packageName)
            }
        }
        Log.w(TAG, "❌ App non trouvée: $appName")
        return false
    }

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

    fun isAppInstalled(appName: String): Boolean {
        val normalizedName = appName.lowercase()
        val installedApps = getInstalledApps()
        return installedApps.keys.any { it.contains(normalizedName) } || systemApps.keys.any { normalizedName.contains(it) }
    }

    fun getAppSuggestions(input: String): List<String> {
        val suggestions = mutableListOf<String>()
        val installedApps = getInstalledApps()
        for (appName in installedApps.keys) {
            if (appName.contains(input.lowercase()) || input.lowercase().contains(appName)) {
                suggestions.add(appName)
            }
        }
        return suggestions.take(5)
    }
}
