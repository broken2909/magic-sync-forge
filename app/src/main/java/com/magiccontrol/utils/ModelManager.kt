package com.magiccontrol.utils

import android.content.Context
import android.util.Log
import org.json.JSONObject
import java.io.InputStream

object ModelManager {
    private const val TAG = "ModelManager"

    fun getAvailableModels(context: Context): List<ModelInfo> {
        return try {
            val inputStream: InputStream = context.assets.open("models/models_config.json")
            val jsonString = inputStream.bufferedReader().use { it.readText() }
            val jsonObject = JSONObject(jsonString)
            val modelsArray = jsonObject.getJSONArray("available_models")

            val models = mutableListOf<ModelInfo>()
            for (i in 0 until modelsArray.length()) {
                val modelObj = modelsArray.getJSONObject(i)
                models.add(
                    ModelInfo(
                        code = modelObj.getString("code"),
                        name = modelObj.getString("name"),
                        size = modelObj.getString("size"),
                        enabled = modelObj.getBoolean("enabled"),
                        builtin = modelObj.optBoolean("builtin", true),
                        path = modelObj.optString("path", ""),
                        downloadUrls = modelObj.optJSONArray("download_urls")?.let { urls ->
                            (0 until urls.length()).map { urls.getString(it) }
                        } ?: emptyList(),
                        sha256 = modelObj.optString("sha256", "")
                    )
                )
            }
            models
        } catch (e: Exception) {
            Log.e(TAG, "Erreur chargement configuration models", e)
            emptyList()
        }
    }

    fun getModelPathForLanguage(context: Context, language: String): String {
        return when (language) {
            "fr" -> "models/vosk-model-small-fr-0.22"
            "en" -> "models/vosk-model-small-en-0.22"
            else -> "models/vosk-model-small-fr-0.22"
        }
    }

    fun isModelAvailable(context: Context, language: String): Boolean {
        return try {
            val modelPath = getModelPathForLanguage(context, language)
            context.assets.list(modelPath)?.isNotEmpty() ?: false
        } catch (e: Exception) {
            false
        }
    }

    fun getDownloadableModels(context: Context): List<ModelInfo> {
        return getAvailableModels(context).filter { !it.builtin && it.enabled }
    }

    fun getBuiltinModels(context: Context): List<ModelInfo> {
        return getAvailableModels(context).filter { it.builtin && it.enabled }
    }
}

data class ModelInfo(
    val code: String,
    val name: String,
    val size: String,
    val enabled: Boolean,
    val builtin: Boolean = true,
    val path: String = "",
    val downloadUrls: List<String> = emptyList(),
    val sha256: String = ""
)
