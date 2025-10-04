package com.magiccontrol.utils

import android.content.Context
import android.util.Log
import org.json.JSONObject
import java.io.File
import java.io.InputStream

object ModelManager {
    private const val TAG = "ModelManager"
    
    // Modèles intégrés (small)
    private val BUILTIN_MODELS = mapOf(
        "fr-small" to "models/vosk-model-small-fr-0.22",
        "en-small" to "models/vosk-model-small-en-us-0.22"
    )
    
    // Modèles téléchargeables (large)
    private val DOWNLOADABLE_MODELS = mapOf(
        "fr-large" to ModelInfo(
            code = "fr-large",
            name = "Français (Large)",
            size = "1.4GB",
            enabled = true,
            downloadUrl = "https://alphacephei.com/vosk/models/vosk-model-small-fr-0.22.zip",
            isBuiltin = false
        ),
        "en-large" to ModelInfo(
            code = "en-large", 
            name = "English (Large)",
            size = "1.8GB",
            enabled = true,
            downloadUrl = "https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.22.zip",
            isBuiltin = false
        )
    )
    
    /**
     * Charge la configuration des models disponibles
     */
    fun getAvailableModels(context: Context): List<ModelInfo> {
        val models = mutableListOf<ModelInfo>()
        
        // Ajouter modèles intégrés
        BUILTIN_MODELS.forEach { (code, path) ->
            models.add(
                ModelInfo(
                    code = code,
                    name = when (code) {
                        "fr-small" -> "Français (Small)"
                        "en-small" -> "English (Small)" 
                        else -> code
                    },
                    size = "40MB",
                    enabled = true,
                    downloadUrl = null,
                    isBuiltin = true
                )
            )
        }
        
        // Ajouter modèles téléchargeables
        models.addAll(DOWNLOADABLE_MODELS.values)
        
        return models
    }
    
    /**
     * Récupère le model path selon la langue et type
     */
    fun getModelPathForLanguage(context: Context, language: String, modelType: String = "small"): String {
        val modelCode = "$language-$modelType"
        
        // Si modèle intégré
        if (BUILTIN_MODELS.containsKey(modelCode)) {
            return BUILTIN_MODELS[modelCode]!!
        }
        
        // Si modèle téléchargé
        val downloadedPath = getDownloadedModelPath(context, modelCode)
        if (File(downloadedPath).exists()) {
            return downloadedPath
        }
        
        // Fallback sur small intégré
        return BUILTIN_MODELS["$language-small"] ?: BUILTIN_MODELS["fr-small"]!!
    }
    
    /**
     * Vérifie si un model est disponible (intégré ou téléchargé)
     */
    fun isModelAvailable(context: Context, language: String, modelType: String = "small"): Boolean {
        val modelCode = "$language-$modelType"
        
        // Vérifier modèle intégré
        if (BUILTIN_MODELS.containsKey(modelCode)) {
            return try {
                val modelPath = BUILTIN_MODELS[modelCode]!!
                context.assets.list(modelPath)?.isNotEmpty() ?: false
            } catch (e: Exception) {
                false
            }
        }
        
        // Vérifier modèle téléchargé
        return File(getDownloadedModelPath(context, modelCode)).exists()
    }
    
    /**
     * Chemin local pour modèles téléchargés
     */
    private fun getDownloadedModelPath(context: Context, modelCode: String): String {
        return File(context.filesDir, "models/$modelCode").absolutePath
    }
    
    /**
     * Récupère les infos d'un modèle téléchargeable
     */
    fun getDownloadableModel(modelCode: String): ModelInfo? {
        return DOWNLOADABLE_MODELS[modelCode]
    }
    
    /**
     * Ajoute un modèle personnalisé via URL
     */
    fun addCustomModel(context: Context, modelCode: String, downloadUrl: String, modelName: String, size: String) {
        // À implémenter dans ModelDownloadService
        Log.d(TAG, "Modèle personnalisé ajouté: $modelCode - $downloadUrl")
    }
}

data class ModelInfo(
    val code: String,
    val name: String,
    val size: String,
    val enabled: Boolean,
    val downloadUrl: String? = null,
    val isBuiltin: Boolean = true
)
