package com.magiccontrol.ui.settings

import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup

class SettingsFragment : Fragment() {

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        // Layout simple temporaire pour éviter les erreurs de compilation
        return inflater.inflate(android.R.layout.simple_list_item_1, container, false)
    }

    companion object {
        fun newInstance() = SettingsFragment()
    }
}
