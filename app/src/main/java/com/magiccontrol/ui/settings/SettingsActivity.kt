package com.magiccontrol.ui.settings

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.*
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import com.magiccontrol.R
import com.magiccontrol.tts.TTSManager
import com.magiccontrol.utils.PreferencesManager
import com.magiccontrol.utils.ModelManager
import com.magiccontrol.service.WakeWordService
import java.io.File
import java.io.FileOutputStream
import java.util.zip.ZipFile

class SettingsActivity : AppCompatActivity() {

    private lateinit var keywordEditText: EditText
    private lateinit var languageSpinner: Spinner
    private lateinit var voiceFeedbackSwitch: Switch
    private lateinit var voiceSpeedSeekBar: SeekBar
    private lateinit var uploadModelButton: Button
    private lateinit var testVoiceButton: Button
    private lateinit var saveButton: Button
    
    private val TAG = "SettingsActivity"
    
    private val filePickerLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (result.resultCode == Activity.RESULT_OK) {
            result.data?.data?.let { uri ->
                processUploadedModel(uri)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createSettingsUI()
        loadCurrentSettings()
        
        TTSManager.speak(this, "Paramètres Magic Control")
        Log.d(TAG, "Interface paramètres ouverte")
    }
    
    private fun createSettingsUI() {
        val scrollView = ScrollView(this)
        val linearLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(32, 32, 32, 32)
        }
        
        // TITRE
        val titleText = TextView(this).apply {
            text = "⚙️ Paramètres Magic Control"
            textSize = 24f
            setPadding(0, 0, 0, 32)
            setTypeface(null, android.graphics.Typeface.BOLD)
        }
        linearLayout.addView(titleText)
        
        // SECTION MOT-CLÉ
        addSectionTitle(linearLayout, "🎯 Mot d'activation")
        keywordEditText = EditText(this).apply {
            hint = "Entrez votre mot d'activation"
            textSize = 18f
            setPadding(16, 16, 16, 16)
        }
        linearLayout.addView(keywordEditText)
        
        addDescription(linearLayout, "Mot pour activer la reconnaissance vocale")
        
        // SECTION LANGUE
        addSectionTitle(linearLayout, "🌍 Langue de reconnaissance")
        languageSpinner = Spinner(this).apply {
            val languages = arrayOf("Français", "English")
            val adapter = ArrayAdapter(this@SettingsActivity, android.R.layout.simple_spinner_item, languages)
            adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
            this.adapter = adapter
            onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
                override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                    val selectedLang = if (position == 0) "fr" else "en"
                    Log.d(TAG, "Langue sélectionnée: $selectedLang")
                }
                override fun onNothingSelected(parent: AdapterView<*>?) {}
            }
        }
        linearLayout.addView(languageSpinner)
        
        addDescription(linearLayout, "Sélectionnez la langue pour la reconnaissance")
        
        // SECTION UPLOAD MODÈLE
        addSectionTitle(linearLayout, "📦 Modèle personnalisé")
        uploadModelButton = Button(this).apply {
            text = "📁 Importer modèle VOSK"
            textSize = 16f
            setPadding(16, 16, 16, 16)
            setOnClickListener { openFilePicker() }
        }
        linearLayout.addView(uploadModelButton)
        
        addDescription(linearLayout, "Importez un modèle VOSK (.zip) depuis le stockage")
        
        // SECTION FEEDBACK VOCAL
        addSectionTitle(linearLayout, "🔊 Feedback vocal")
        voiceFeedbackSwitch = Switch(this).apply {
            text = "Activer confirmations vocales"
            textSize = 16f
            setPadding(16, 16, 16, 16)
        }
        linearLayout.addView(voiceFeedbackSwitch)
        
        // SECTION VITESSE VOCALE
        addSectionTitle(linearLayout, "⚡ Vitesse de la voix")
        val speedLayout = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
        }
        
        val slowLabel = TextView(this).apply { text = "Lent" }
        voiceSpeedSeekBar = SeekBar(this).apply {
            max = 100
            setPadding(32, 16, 32, 16)
        }
        val fastLabel = TextView(this).apply { text = "Rapide" }
        
        speedLayout.addView(slowLabel)
        speedLayout.addView(voiceSpeedSeekBar)
        speedLayout.addView(fastLabel)
        linearLayout.addView(speedLayout)
        
        // SECTION TEST
        addSectionTitle(linearLayout, "🎤 Test")
        testVoiceButton = Button(this).apply {
            text = "🔊 Tester la voix"
            textSize = 16f
            setPadding(16, 16, 16, 16)
            setOnClickListener { testVoiceSettings() }
        }
        linearLayout.addView(testVoiceButton)
        
        // BOUTONS D'ACTION
        val buttonLayout = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(0, 32, 0, 0)
        }
        
        saveButton = Button(this).apply {
            text = "✅ Sauvegarder"
            textSize = 18f
            setPadding(32, 16, 32, 16)
            setOnClickListener { saveSettings() }
        }
        
        val cancelButton = Button(this).apply {
            text = "❌ Annuler"
            textSize = 18f
            setPadding(32, 16, 32, 16)
            setOnClickListener { 
                TTSManager.speak(this@SettingsActivity, "Paramètres annulés")
                finish() 
            }
        }
        
        buttonLayout.addView(saveButton)
        buttonLayout.addView(cancelButton)
        linearLayout.addView(buttonLayout)
        
        scrollView.addView(linearLayout)
        setContentView(scrollView)
    }
    
    private fun addSectionTitle(parent: LinearLayout, title: String) {
        val textView = TextView(this).apply {
            text = title
            textSize = 20f
            setPadding(0, 24, 0, 8)
            setTypeface(null, android.graphics.Typeface.BOLD)
        }
        parent.addView(textView)
    }
    
    private fun addDescription(parent: LinearLayout, description: String) {
        val textView = TextView(this).apply {
            text = description
            textSize = 14f
            setPadding(0, 4, 0, 16)
            alpha = 0.7f
        }
        parent.addView(textView)
    }
    
    private fun loadCurrentSettings() {
        // Charger mot-clé actuel
        keywordEditText.setText(PreferencesManager.getActivationKeyword(this))
        
        // Charger langue actuelle
        val currentLang = PreferencesManager.getCurrentLanguage(this)
        languageSpinner.setSelection(if (currentLang == "fr") 0 else 1)
        
        // Charger feedback vocal
        voiceFeedbackSwitch.isChecked = PreferencesManager.isVoiceFeedbackEnabled(this)
        
        // Charger vitesse vocal
        voiceSpeedSeekBar.progress = PreferencesManager.getVoiceSpeed(this)
        
        Log.d(TAG, "Paramètres actuels chargés")
    }
    
    private fun openFilePicker() {
        val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
            type = "application/zip"
            addCategory(Intent.CATEGORY_OPENABLE)
        }
        
        TTSManager.speak(this, "Sélectionnez un fichier modèle")
        filePickerLauncher.launch(Intent.createChooser(intent, "Sélectionner modèle VOSK"))
    }
    
    private fun processUploadedModel(uri: Uri) {
        try {
            Log.d(TAG, "Traitement modèle uploadé: $uri")
            TTSManager.speak(this, "Installation du modèle en cours")
            
            val inputStream = contentResolver.openInputStream(uri)
            val tempFile = File(cacheDir, "uploaded_model.zip")
            
            inputStream?.use { input ->
                FileOutputStream(tempFile).use { output ->
                    input.copyTo(output)
                }
            }
            
            // Extract and validate the model
            Thread {
                val success = extractCustomModel(tempFile)
                runOnUiThread {
                    if (success) {
                        TTSManager.speak(this, "Modèle installé avec succès")
                        showMessage("✅ Modèle installé", "Le modèle personnalisé a été installé avec succès")
                    } else {
                        TTSManager.speak(this, "Erreur installation modèle")
                        showMessage("❌ Erreur", "Impossible d'installer le modèle. Vérifiez le format.")
                    }
                }
            }.start()
            
        } catch (e: Exception) {
            Log.e(TAG, "Erreur traitement modèle", e)
            TTSManager.speak(this, "Erreur traitement modèle")
        }
    }
    
    private fun extractCustomModel(zipFile: File): Boolean {
        return try {
            val customModelsDir = File(filesDir, "models/custom")
            customModelsDir.mkdirs()
            
            ZipFile(zipFile).use { zip ->
                zip.entries().asSequence().forEach { entry ->
                    if (!entry.isDirectory) {
                        val outputFile = File(customModelsDir, entry.name)
                        outputFile.parentFile?.mkdirs()
                        
                        zip.getInputStream(entry).use { input ->
                            FileOutputStream(outputFile).use { output ->
                                input.copyTo(output)
                            }
                        }
                    }
                }
            }
            
            // Verify model validity (check for required files)
            val hasConf = File(customModelsDir, "conf/mfcc.conf").exists()
            val hasAm = File(customModelsDir, "am").exists()
            
            Log.d(TAG, "Modèle personnalisé extracté - valide: ${hasConf && hasAm}")
            hasConf && hasAm
            
        } catch (e: Exception) {
            Log.e(TAG, "Erreur extraction modèle personnalisé", e)
            false
        }
    }
    
    private fun testVoiceSettings() {
        val speed = voiceSpeedSeekBar.progress
        val enabled = voiceFeedbackSwitch.isChecked
        
        if (enabled) {
            // Apply current speed setting temporarily for test
            TTSManager.setVoiceSpeed(this, speed)
            TTSManager.speak(this, "Test de la voix avec vitesse $speed pour cent. Magic Control fonctionne parfaitement.")
        } else {
            showMessage("ℹ️ Info", "Feedback vocal désactivé")
        }
    }
    
    private fun saveSettings() {
        try {
            // Sauvegarder mot-clé
            val newKeyword = keywordEditText.text.toString().trim()
            if (newKeyword.isNotEmpty()) {
                PreferencesManager.setActivationKeyword(this, newKeyword)
            }
            
            // Sauvegarder langue
            val selectedLanguage = if (languageSpinner.selectedItemPosition == 0) "fr" else "en"
            val currentLanguage = PreferencesManager.getCurrentLanguage(this)
            
            if (selectedLanguage != currentLanguage) {
                PreferencesManager.setCurrentLanguage(this, selectedLanguage)
                Log.d(TAG, "Langue changée: $currentLanguage -> $selectedLanguage")
            }
            
            // Sauvegarder feedback vocal
            PreferencesManager.setVoiceFeedbackEnabled(this, voiceFeedbackSwitch.isChecked)
            
            // Sauvegarder vitesse vocal
            PreferencesManager.setVoiceSpeed(this, voiceSpeedSeekBar.progress)
            
            Log.d(TAG, "Paramètres sauvegardés")
            TTSManager.speak(this, "Paramètres sauvegardés. Redémarrage des services.")
            
            // Redémarrer les services si nécessaire
            restartVoiceServices()
            
            showMessage("✅ Succès", "Paramètres sauvegardés et appliqués") {
                finish()
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Erreur sauvegarde paramètres", e)
            TTSManager.speak(this, "Erreur sauvegarde")
        }
    }
    
    private fun restartVoiceServices() {
        try {
            // Stop current service
            stopService(Intent(this, WakeWordService::class.java))
            
            // Restart with new settings
            Thread.sleep(500)
            startService(Intent(this, WakeWordService::class.java))
            
            Log.d(TAG, "Services vocaux redémarrés")
        } catch (e: Exception) {
            Log.e(TAG, "Erreur redémarrage services", e)
        }
    }
    
    private fun showMessage(title: String, message: String, onDismiss: (() -> Unit)? = null) {
        AlertDialog.Builder(this)
            .setTitle(title)
            .setMessage(message)
            .setPositiveButton("OK") { dialog, _ -> 
                dialog.dismiss()
                onDismiss?.invoke()
            }
            .show()
    }
}
