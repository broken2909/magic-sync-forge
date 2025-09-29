package com.magiccontrol

import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)  // ✅ Z.ai exact

        setupToolbar()     // ✅ Z.ai exact
        setupButtons()     // ✅ Z.ai exact
        
        // ✅ TEST STABILITÉ - Services désactivés temporairement
        Toast.makeText(this, "Application stable - Z.ai", Toast.LENGTH_LONG).show()
    }

    private fun setupToolbar() {
        val toolbar = findViewById<androidx.appcompat.widget.Toolbar>(R.id.toolbar)
        setSupportActionBar(toolbar)  // ✅ Z.ai method
    }

    private fun setupButtons() {
        val voiceButton = findViewById<android.widget.ImageButton>(R.id.voice_button)
        val settingsButton = findViewById<android.widget.Button>(R.id.settings_button)

        voiceButton.setOnClickListener {
            Toast.makeText(this, "Commande vocale", Toast.LENGTH_SHORT).show()
        }

        settingsButton.setOnClickListener {
            Toast.makeText(this, "Paramètres", Toast.LENGTH_SHORT).show()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
    }
}
