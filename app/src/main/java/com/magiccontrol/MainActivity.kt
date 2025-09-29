package com.magiccontrol

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        Toast.makeText(this, "MagicControl démarré", Toast.LENGTH_SHORT).show()
        
        // Bouton settings
        findViewById<android.widget.Button>(R.id.settings_button)?.setOnClickListener {
            val intent = Intent(this, com.magiccontrol.ui.settings.SettingsActivity::class.java)
            startActivity(intent)
        }
        
        // Démarrer le service vocal
        startWakeWordService()
    }

    private fun startWakeWordService() {
        val serviceIntent = Intent(this, com.magiccontrol.service.WakeWordService::class.java)
        startService(serviceIntent)
        Toast.makeText(this, "Service vocal démarré", Toast.LENGTH_SHORT).show()
    }
}
