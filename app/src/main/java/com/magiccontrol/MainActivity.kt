package com.magiccontrol

import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.magiccontrol.utils.PreferencesManager
import com.magiccontrol.tts.TTSManager

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // Toast bref à chaque ouverture
        Toast.makeText(this, "MagicControl activé", Toast.LENGTH_SHORT).show()
        
        // Synthèse vocale uniquement à la première utilisation (gestion simple)
        val prefs = getSharedPreferences("magic_control_prefs", MODE_PRIVATE)
        if (prefs.getBoolean("first_launch", true)) {
            TTSManager.speak(this, "Bienvenue dans MagicControl, votre assistant vocal offline")
            prefs.edit().putBoolean("first_launch", false).apply()
        }
    }
}
