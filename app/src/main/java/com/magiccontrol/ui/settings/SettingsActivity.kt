package com.magiccontrol.ui.settings

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.magiccontrol.R

class SettingsActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.settings_activity)
        
        // TEST: Sans fragment pour isoler le problème
        // supportFragmentManager
        //     .beginTransaction()
        //     .replace(R.id.settings_container, SettingsFragment())
        //     .commit()
    }
}
