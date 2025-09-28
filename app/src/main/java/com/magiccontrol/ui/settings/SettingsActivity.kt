package com.magiccontrol.ui.settings

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.magiccontrol.R

class SettingsActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.settings_activity)
        
        // STRUCTURE Z.AI ORIGINALE
        setSupportActionBar(findViewById(R.id.toolbar))
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        
        try {
            supportFragmentManager
                .beginTransaction()
                .replace(R.id.settings_container, SettingsFragment())
                .commit()
        } catch (e: Exception) {
            android.widget.Toast.makeText(this, "Erreur fragment: ${e.message}", android.widget.Toast.LENGTH_LONG).show()
        }
    }

    override fun onSupportNavigateUp(): Boolean {
        finish()
        return true
    }
}
