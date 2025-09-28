package com.magiccontrol.ui.settings

import android.os.Bundle
import android.util.Log
import com.magiccontrol.ui.settings.SettingsFragment
import androidx.appcompat.app.AppCompatActivity
import com.magiccontrol.R

class SettingsActivity : AppCompatActivity() {
    private val TAG = "SettingsActivity"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "onCreate démarré")
        
        try {
            setContentView(R.layout.settings_activity)
            Log.d(TAG, "setContentView réussi")
            
            // Configuration de la toolbar
            val toolbar = findViewById<androidx.appcompat.widget.Toolbar>(R.id.toolbar)
            Log.d(TAG, "Toolbar trouvée: $toolbar")
            
            setSupportActionBar(toolbar)
            supportActionBar?.setDisplayHomeAsUpEnabled(true)
            Log.d(TAG, "Toolbar configurée")
            
            // Ajout du fragment de préférences
            supportFragmentManager
                .beginTransaction()
                .replace(R.id.settings_container, SettingsFragment())
                .commit()
            Log.d(TAG, "Fragment ajouté")
            
        } catch (e: Exception) {
            Log.e(TAG, "CRASH dans onCreate: ${e.message}", e)
            throw e // Relancer pour voir le crash
        }
    }

    override fun onSupportNavigateUp(): Boolean {
        finish()
        return true
    }
}
