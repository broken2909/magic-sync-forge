package com.magiccontrol.ui.settings

import android.os.Bundle
import androidx.preference.PreferenceFragmentCompat
import com.magiccontrol.R

class LanguagesSettingsFragment : PreferenceFragmentCompat() {
    
    override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
        // JUSTE charger les préférences - rien d'autre
        setPreferencesFromResource(R.xml.preferences, rootKey)
    }
}
