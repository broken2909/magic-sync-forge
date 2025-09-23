package com.magiccontrol.ui.settings

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.magiccontrol.utils.PreferencesManager

class GeneralSettingsFragment : Fragment() {

    private lateinit var prefs: PreferencesManager

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        prefs = PreferencesManager()
        
        val view = inflater.inflate(R.layout.fragment_general_settings, container, false)
        
        // Configuration audio
        setupAudioSettings(view)
        
        // Configuration sécurité
        setupSecuritySettings(view)
        
        // Configuration commandes système
        setupSystemCommands(view)
        
        return view
    }

    private fun setupAudioSettings(view: View) {
        val sensitivitySeekBar = view.findViewById<android.widget.SeekBar>(R.id.microphone_sensitivity)
        val volumeSeekBar = view.findViewById<android.widget.SeekBar>(R.id.tts_volume)
        val stereoSwitch = view.findViewById<android.widget.Switch>(R.id.stereo_audio_switch)
        val hapticSwitch = view.findViewById<android.widget.Switch>(R.id.haptic_feedback_switch)
        
        sensitivitySeekBar.progress = prefs.getMicrophoneSensitivity(requireContext())
        volumeSeekBar.progress = prefs.getTtsVolume(requireContext())
        stereoSwitch.isChecked = prefs.isStereoAudioEnabled(requireContext())
        hapticSwitch.isChecked = prefs.isHapticFeedbackEnabled(requireContext())
        
        sensitivitySeekBar.setOnSeekBarChangeListener(createSeekBarListener { progress ->
            prefs.setMicrophoneSensitivity(requireContext(), progress)
        })
        
        volumeSeekBar.setOnSeekBarChangeListener(createSeekBarListener { progress ->
            prefs.setTtsVolume(requireContext(), progress)
        })
        
        stereoSwitch.setOnCheckedChangeListener { _, isChecked ->
            prefs.setStereoAudioEnabled(requireContext(), isChecked)
        }
        
        hapticSwitch.setOnCheckedChangeListener { _, isChecked ->
            prefs.setHapticFeedbackEnabled(requireContext(), isChecked)
        }
    }

    private fun setupSecuritySettings(view: View) {
        val confirmationSwitch = view.findViewById<android.widget.Switch>(R.id.voice_confirmation_switch)
        val delaySeekBar = view.findViewById<android.widget.SeekBar>(R.id.confirmation_delay_seekbar)
        val delayText = view.findViewById<android.widget.TextView>(R.id.delay_value_text)
        
        confirmationSwitch.isChecked = prefs.isVoiceConfirmationEnabled(requireContext())
        delaySeekBar.progress = prefs.getConfirmationDelay(requireContext())
        delayText.text = "${delaySeekBar.progress} secondes"
        
        confirmationSwitch.setOnCheckedChangeListener { _, isChecked ->
            prefs.setVoiceConfirmationEnabled(requireContext(), isChecked)
        }
        
        delaySeekBar.setOnSeekBarChangeListener(object : android.widget.SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: android.widget.SeekBar?, progress: Int, fromUser: Boolean) {
                delayText.text = "$progress secondes"
                prefs.setConfirmationDelay(requireContext(), progress)
            }
            override fun onStartTrackingTouch(seekBar: android.widget.SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: android.widget.SeekBar?) {}
        })
    }

    private fun setupSystemCommands(view: View) {
        val volumeSwitch = view.findViewById<android.widget.Switch>(R.id.volume_control_switch)
        val wifiSwitch = view.findViewById<android.widget.Switch>(R.id.wifi_control_switch)
        val navSwitch = view.findViewById<android.widget.Switch>(R.id.navigation_control_switch)
        
        volumeSwitch.isChecked = prefs.isVolumeControlEnabled(requireContext())
        wifiSwitch.isChecked = prefs.isWifiControlEnabled(requireContext())
        navSwitch.isChecked = prefs.isNavigationControlEnabled(requireContext())
        
        volumeSwitch.setOnCheckedChangeListener { _, isChecked ->
            prefs.setVolumeControlEnabled(requireContext(), isChecked)
        }
        wifiSwitch.setOnCheckedChangeListener { _, isChecked ->
            prefs.setWifiControlEnabled(requireContext(), isChecked)
        }
        navSwitch.setOnCheckedChangeListener { _, isChecked ->
            prefs.setNavigationControlEnabled(requireContext(), isChecked)
        }
    }

    private fun createSeekBarListener(onProgressChanged: (Int) -> Unit): android.widget.SeekBar.OnSeekBarChangeListener {
        return object : android.widget.SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: android.widget.SeekBar?, progress: Int, fromUser: Boolean) {
                onProgressChanged(progress)
            }
            override fun onStartTrackingTouch(seekBar: android.widget.SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: android.widget.SeekBar?) {}
        }
    }
}
