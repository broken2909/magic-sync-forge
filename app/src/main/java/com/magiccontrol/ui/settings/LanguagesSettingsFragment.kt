package com.magiccontrol.ui.settings

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment

class LanguagesSettingsFragment : Fragment() {
    
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        // Retourner une vue simple pour l'instant
        return android.widget.TextView(requireContext()).apply {
            text = "Paramètres des langues - En développement"
            textSize = 18f
            setPadding(50, 50, 50, 50)
        }
    }
}
