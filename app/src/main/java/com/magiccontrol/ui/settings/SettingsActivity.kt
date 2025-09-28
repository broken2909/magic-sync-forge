package com.magiccontrol.ui.settings

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.magiccontrol.R

class SettingsActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // TEST: Layout simple sans fragment
        setContentView(R.layout.settings_activity)
        
        // Configuration basique de la toolbar
        val toolbar = findViewById<androidx.appcompat.widget.Toolbar>(R.id.toolbar)
        setSupportActionBar(toolbar)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        
        // MESSAGE pour confirmer que l'activité s'ouvre
        android.widget.Toast.makeText(this, "SettingsActivity ouvert", android.widget.Toast.LENGTH_SHORT).show()
    }

    override fun onSupportNavigateUp(): Boolean {
        finish()
        return true
    }
}
