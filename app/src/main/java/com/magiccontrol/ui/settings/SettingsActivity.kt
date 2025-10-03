package com.magiccontrol.ui.settings
import android.os.Handler
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.*
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import com.magiccontrol.tts.TTSManager
import com.magiccontrol.utils.PreferencesManager
import com.magiccontrol.service.WakeWordService

class SettingsActivity : AppCompatActivity() {
    
    private val TAG = "SettingsActivity"
    private var keywordEditText: EditText? = null
    private var languageSpinner: Spinner? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "⚙️ Ouverture paramètres")
        
        try {
            createSimpleSettingsUI()
            loadCurrentSettings()
            TTSManager.speak(this, "Paramètres Magic Control")
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur paramètres", e)
            showErrorAndClose("Erreur ouverture paramètres")
        }
    }
    
    private fun createSimpleSettingsUI() {
        // Layout vertical simple
        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(50, 50, 50, 50)
        }
        
        // Titre
        val title = TextView(this).apply {
            text = "⚙️ Paramètres Magic Control"
            textSize = 20f
            setPadding(0, 0, 0, 30)
        }
        layout.addView(title)
        
        // Mot-clé
        val keywordLabel = TextView(this).apply {
            text = "Mot d'activation:"
            textSize = 16f
            setPadding(0, 10, 0, 5)
        }
        layout.addView(keywordLabel)
        
        keywordEditText = EditText(this).apply {
            hint = "Ex: Magic, Assistant..."
            setPadding(20, 20, 20, 20)
        }
        layout.addView(keywordEditText)
        
        // Langue
        val languageLabel = TextView(this).apply {
            text = "Langue:"
            textSize = 16f
            setPadding(0, 20, 0, 5)
        }
        layout.addView(languageLabel)
        
        languageSpinner = Spinner(this).apply {
            val languages = arrayOf("Français", "English", "Español")
            adapter = ArrayAdapter(this@SettingsActivity, android.R.layout.simple_spinner_item, languages)
        }
        layout.addView(languageSpinner)
        
        // Boutons
        val buttonLayout = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(0, 30, 0, 0)
        }
        
        val saveButton = Button(this).apply {
            text = "💾 Sauvegarder"
            setOnClickListener { saveSettings() }
            layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f).apply {
                setMargins(0, 0, 10, 0)
            }
        }
        
        val testButton = Button(this).apply {
            text = "🎤 Test"
            setOnClickListener { testVoice() }
            layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f).apply {
                setMargins(10, 0, 10, 0)
            }
        }
        
        val backButton = Button(this).apply {
            text = "🔙 Retour"
            setOnClickListener { finishSafely() }
            layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f).apply {
                setMargins(10, 0, 0, 0)
            }
        }
        
        buttonLayout.addView(saveButton)
        buttonLayout.addView(testButton)
        buttonLayout.addView(backButton)
        layout.addView(buttonLayout)
        
        setContentView(layout)
        Log.d(TAG, "✅ Interface paramètres créée")
    }
    
    private fun loadCurrentSettings() {
        try {
            val keyword = PreferencesManager.getActivationKeyword(this)
            keywordEditText?.setText(keyword)
            
            val language = PreferencesManager.getCurrentLanguage(this)
            val position = when (language) {
                "fr" -> 0
                "en" -> 1
                "es" -> 2
                else -> 0
            }
            languageSpinner?.setSelection(position)
            
            Log.d(TAG, "✅ Paramètres chargés - Mot: $keyword, Langue: $language")
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur chargement paramètres", e)
        }
    }
    
    private fun saveSettings() {
        try {
            val keyword = keywordEditText?.text?.toString()?.trim() ?: "magic"
            if (keyword.isNotEmpty()) {
                PreferencesManager.setActivationKeyword(this, keyword)
            }
            
            val language = when (languageSpinner?.selectedItemPosition ?: 0) {
                0 -> "fr"
                1 -> "en"
                2 -> "es"
                else -> "fr"
            }
            PreferencesManager.setCurrentLanguage(this, language)
            
            TTSManager.speak(this, "Paramètres sauvegardés")
            restartService()
            
            showMessage("✅ Succès", "Paramètres sauvegardés avec succès")
            
            Log.d(TAG, "✅ Paramètres sauvegardés - Mot: $keyword, Langue: $language")
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur sauvegarde", e)
            showMessage("❌ Erreur", "Erreur sauvegarde: ${e.message}")
        }
    }
    
    private fun testVoice() {
        TTSManager.speak(this, "Test de la synthèse vocale Magic Control. Système opérationnel.")
    }
    
    private fun restartService() {
        try {
            // Redémarrer le service audio
            val stopIntent = Intent(this, WakeWordService::class.java)
            stopService(stopIntent)
            
            Handler(mainLooper).postDelayed({
                val startIntent = Intent(this, WakeWordService::class.java)
                startService(startIntent)
                Log.d(TAG, "🔄 Service redémarré")
            }, 1000L)
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur redémarrage service", e)
        }
    }
    
    private fun showMessage(title: String, message: String) {
        AlertDialog.Builder(this)
            .setTitle(title)
            .setMessage(message)
            .setPositiveButton("OK") { dialog, _ -> dialog.dismiss() }
            .show()
    }
    
    private fun showErrorAndClose(message: String) {
        AlertDialog.Builder(this)
            .setTitle("❌ Erreur Critique")
            .setMessage("$message\nL'application va fermer les paramètres.")
            .setPositiveButton("OK") { _, _ -> finishSafely() }
            .setCancelable(false)
            .show()
    }
    
    private fun finishSafely() {
        try {
            finish()
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur fermeture", e)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "🔚 Paramètres fermés")
    }
}
