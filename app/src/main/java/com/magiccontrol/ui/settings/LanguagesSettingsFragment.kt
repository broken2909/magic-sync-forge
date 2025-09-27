package com.magiccontrol.ui.settings

import android.os.Bundle
import androidx.preference.PreferenceFragmentCompat

class LanguagesSettingsFragment : PreferenceFragmentCompat() {
    override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
        // Charger les préférences depuis le fichier XML
        setPreferencesFromResource(R.xml.preferences, rootKey)
        
        // Écouteurs pour les préférences
        setupPreferenceListeners()
    }
    
    private fun setupPreferenceListeners() {
        // Écouteur pour le mot d'activation
        findPreference<androidx.preference.EditTextPreference>("activation_keyword")?.setOnPreferenceChangeListener { _, newValue ->
            val keyword = newValue as? String ?: "magic"
            // Mettre à jour le mot d'activation dans PreferencesManager
            com.magiccontrol.utils.PreferencesManager.setActivationKeyword(requireContext(), keyword)
            true
        }
        
        // Écouteur pour la vitesse de la voix
        findPreference<androidx.preference.SeekBarPreference>("voice_speed")?.setOnPreferenceChangeListener { _, newValue ->
            val speed = newValue as? Int ?: 100
            com.magiccontrol.utils.PreferencesManager.setVoiceSpeed(requireContext(), speed)
            // Mettre à jour TTSManager
            com.magiccontrol.tts.TTSManager.shutdown() // Redémarrer TTS avec nouvelle vitesse
            true
        }
        
        // Écouteur pour le feedback vocal
        findPreference<androidx.preference.SwitchPreference>("voice_feedback")?.setOnPreferenceChangeListener { _, newValue ->
            val enabled = newValue as? Boolean ?: true
            com.magiccontrol.utils.PreferencesManager.setVoiceFeedbackEnabled(requireContext(), enabled)
            true
        }
        
        // Écouteur pour le téléchargement des langues
        findPreference<androidx.preference.Preference>("download_languages")?.setOnPreferenceClickListener {
            // Ouvrir l'interface de téléchargement des langues
            showLanguageDownloadDialog()
            true
        }
        
        // Écouteur pour trouver le portable
        findPreference<androidx.preference.SwitchPreference>("find_phone")?.setOnPreferenceChangeListener { _, newValue ->
            val enabled = newValue as? Boolean ?: false
            if (enabled) {
                startFindPhoneFeature()
            } else {
                stopFindPhoneFeature()
            }
            true
        }
    }
    
    private fun showLanguageDownloadDialog() {
        // TODO: Implémenter le dialogue de téléchargement des langues
        android.widget.Toast.makeText(requireContext(), "Téléchargement des langues - À implémenter", android.widget.Toast.LENGTH_SHORT).show()
    }
    
    private fun startFindPhoneFeature() {
        // TODO: Démarrer la fonctionnalité "Trouver le portable"
        android.widget.Toast.makeText(requireContext(), "Fonction 'Trouver le portable' activée", android.widget.Toast.LENGTH_SHORT).show()
    }
    
    private fun stopFindPhoneFeature() {
        // TODO: Arrêter la fonctionnalité "Trouver le portable"
        android.widget.Toast.makeText(requireContext(), "Fonction 'Trouver le portable' désactivée", android.widget.Toast.LENGTH_SHORT).show()
    }
}
