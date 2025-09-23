#!/bin/bash
echo "🔧 Correction des dernières erreurs..."

# 1. Corriger WakeWordDetector.kt - ajouter l'import Intent
cat > app/src/main/java/com/magiccontrol/recognizer/WakeWordDetector.kt << 'WAKE'
package com.magiccontrol.recognizer

import android.content.Context
import android.content.Intent
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import android.os.Looper

class WakeWordDetector(private val context: Context) {
    
    private var audioRecord: AudioRecord? = null
    private var isListening = false
    
    fun startListening() {
        if (isListening) return
        
        try {
            audioRecord = AudioRecord(
                MediaRecorder.AudioSource.MIC,
                16000,
                android.media.AudioFormat.CHANNEL_IN_MONO,
                android.media.AudioFormat.ENCODING_PCM_16BIT,
                1024
            )
            
            audioRecord?.startRecording()
            isListening = true
            
            // Simulation de détection pour le moment
            Handler(Looper.getMainLooper()).postDelayed({
                onWakeWordDetected()
            }, 3000)
            
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    
    private fun onWakeWordDetected() {
        // Lancer la reconnaissance complète
        val intent = Intent(context, com.magiccontrol.service.FullRecognitionService::class.java)
        context.startService(intent)
    }
    
    fun stopListening() {
        isListening = false
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
    }
}
WAKE

# 2. Corriger LanguagesSettingsFragment.kt - remplacer par Fragment simple
cat > app/src/main/java/com/magiccontrol/ui/settings/LanguagesSettingsFragment.kt << 'LANG'
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
LANG

# 3. Mettre à jour SettingsActivity.kt pour utiliser Fragment simple
cat > app/src/main/java/com/magiccontrol/ui/settings/SettingsActivity.kt << 'SETTINGS'
package com.magiccontrol.ui.settings

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import androidx.viewpager.widget.ViewPager
import com.google.android.material.tabs.TabLayout

class SettingsActivity : AppCompatActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Créer une interface simple
        val viewPager = ViewPager(this)
        viewPager.id = android.R.id.content
        setContentView(viewPager)
        
        val tabLayout = TabLayout(this)
        addContentView(tabLayout, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
        
        val adapter = SettingsPagerAdapter(supportFragmentManager)
        viewPager.adapter = adapter
        tabLayout.setupWithViewPager(viewPager)
    }
    
    private inner class SettingsPagerAdapter(fm: FragmentManager) : 
        FragmentPagerAdapter(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT) {
        
        private val fragments = listOf(
            GeneralSettingsFragment(),
            LanguagesSettingsFragment()
        )
        
        private val titles = listOf("Général", "Langues")
        
        override fun getItem(position: Int): Fragment = fragments[position]
        override fun getCount(): Int = fragments.size
        override fun getPageTitle(position: Int): CharSequence = titles[position]
    }
}

class GeneralSettingsFragment : Fragment() {
    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return android.widget.TextView(requireContext()).apply {
            text = "Paramètres généraux - En développement"
            textSize = 18f
            setPadding(50, 50, 50, 50)
        }
    }
}
SETTINGS

echo "✅ Dernières corrections appliquées !"
