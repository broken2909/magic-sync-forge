package com.magiccontrol.utils

import android.content.Context
import android.util.Log
import org.json.JSONObject
import java.io.InputStream

object ModelManager {
    private const val TAG = "ModelManager"
    
    /**
     * Charge la configuration des models disponibles
     */
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
                        enabled = modelObj.getBoolean("enabled")
                    )
                )
            }
            models
        } catch (e: Exception) {
            Log.e(TAG, "Erreur chargement configuration models", e)
            emptyList()
        }
    }
    
    /**
     * Récupère le model path selon la langue
     */
    fun getModelPathForLanguage(context: Context, language: String): String {
        return when (language) {
            "fr" -> "models/vosk-model-small-fr-0.22"
            "en" -> "models/vosk-model-small-en-0.22" 
            else -> "models/vosk-model-small-fr-0.22"
        }
    }
    
    /**
     * Vérifie si un model est disponible
     */
    fun isModelAvailable(context: Context, language: String): Boolean {
        return try {
            val modelPath = getModelPathForLanguage(context, language)
            context.assets.list(modelPath)?.isNotEmpty() ?: false
        } catch (e: Exception) {
            false
        }
    }
}

data class ModelInfo(
    val code: String,
    val name: String,
    val size: String,
    val enabled: Boolean
)
