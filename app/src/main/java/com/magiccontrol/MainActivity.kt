package com.magiccontrol

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        setupToolbar()
        setupButtons()
        showWelcomeToast()
    }

    private fun setupToolbar() {
        setSupportActionBar(findViewById(R.id.toolbar))
    }

    private fun setupButtons() {
        findViewById<android.widget.ImageButton>(R.id.voice_button)?.setOnClickListener {
            Toast.makeText(this, "Bouton vocal", Toast.LENGTH_SHORT).show()
        }

        findViewById<android.widget.Button>(R.id.settings_button)?.setOnClickListener {
            val intent = Intent(this, com.magiccontrol.ui.settings.SettingsActivity::class.java)
            startActivity(intent)
        }
    }

    private fun showWelcomeToast() {
        Toast.makeText(this, R.string.welcome_message, Toast.LENGTH_LONG).show()
    }
}
