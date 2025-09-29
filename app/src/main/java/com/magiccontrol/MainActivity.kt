package com.magiccontrol

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        Toast.makeText(this, "TEST - Sans services", Toast.LENGTH_SHORT).show()
        
        // Juste le bouton settings
        findViewById<android.widget.Button>(R.id.settings_button)?.setOnClickListener {
            val intent = Intent(this, com.magiccontrol.ui.settings.SettingsActivity::class.java)
            startActivity(intent)
        }
    }
}
