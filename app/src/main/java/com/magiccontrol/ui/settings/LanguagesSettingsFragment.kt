package com.magiccontrol.ui.settings

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.magiccontrol.utils.PreferencesManager

class LanguagesSettingsFragment : Fragment() {

    private lateinit var prefs: PreferencesManager

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        prefs = PreferencesManager
        
        val view = inflater.inflate(R.layout.fragment_languages_settings, container, false)
        
        // Configuration TTS
        setupTtsSettings(view)
        
        // Configuration langue reconnaissance
        setupRecognitionLanguage(view)
        
        // Configuration mot d'éveil
        setupWakeWord(view)
        
        return view
    }

    private fun setupTtsSettings(view: View) {
        val systemTtsSwitch = view.findViewById<android.widget.Switch>(R.id.system_tts_switch)
        val customLangLabel = view.findViewById<android.widget.TextView>(R.id.custom_lang_label)
        val ttsSpinner = view.findViewById<android.widget.Spinner>(R.id.tts_language_spinner)
        
        systemTtsSwitch.isChecked = prefs.useSystemTtsLanguages(requireContext())
        updateTtsVisibility(systemTtsSwitch.isChecked, customLangLabel, ttsSpinner)
        
        systemTtsSwitch.setOnCheckedChangeListener { _, isChecked ->
            prefs.setUseSystemTtsLanguages(requireContext(), isChecked)
            updateTtsVisibility(isChecked, customLangLabel, ttsSpinner)
        }
        
        // TODO: Implémenter le spinner avec les langues TTS disponibles
        // Pour l'instant, caché car utilisation des langues système par défaut
    }

    private fun setupRecognitionLanguage(view: View) {
        val languageRadioGroup = view.findViewById<android.widget.RadioGroup>(R.id.language_radio_group)
        val currentLanguage = prefs.getLanguage(requireContext())
        
        when (currentLanguage) {
            "fr" -> view.findViewById<android.widget.RadioButton>(R.id.language_french).isChecked = true
            "en" -> view.findViewById<android.widget.RadioButton>(R.id.language_english).isChecked = true
            "es" -> view.findViewById<android.widget.RadioButton>(R.id.language_spanish).isChecked = true
        }
        
        languageRadioGroup.setOnCheckedChangeListener { _, checkedId ->
            when (checkedId) {
                R.id.language_french -> prefs.setLanguage(requireContext(), "fr")
                R.id.language_english -> prefs.setLanguage(requireContext(), "en")
                R.id.language_spanish -> prefs.setLanguage(requireContext(), "es")
            }
        }
    }

    private fun setupWakeWord(view: View) {
        val wakeWordInput = view.findViewById<android.widget.EditText>(R.id.wake_word_input)
        wakeWordInput.setText(prefs.getWakeWord(requireContext()))
        
        wakeWordInput.setOnFocusChangeListener { _, hasFocus ->
            if (!hasFocus) {
                val newWord = wakeWordInput.text.toString().trim().lowercase()
                if (newWord.isNotEmpty()) {
                    prefs.setWakeWord(requireContext(), newWord)
                }
            }
        }
    }

    private fun updateTtsVisibility(useSystem: Boolean, label: android.widget.TextView, spinner: android.widget.Spinner) {
        if (useSystem) {
            label.visibility = View.GONE
            spinner.visibility = View.GONE
        } else {
            label.visibility = View.VISIBLE
            spinner.visibility = View.VISIBLE
        }
    }
}
