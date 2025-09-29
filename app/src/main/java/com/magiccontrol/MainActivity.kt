package com.magiccontrol

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.magiccontrol.service.WakeWordService
import com.magiccontrol.utils.WelcomeManager
import com.magiccontrol.tts.TTSManager

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main) // ✅ Z.ai method

        setupToolbar()
        setupButtons()
        showWelcomeIfNeeded()
        
        // ✅ Services après welcome (timing correct)
        android.os.Handler().postDelayed({
            startWakeWordService()
        }, 2000)
    }

    private fun setupToolbar() {
        val toolbar = findViewById<androidx.appcompat.widget.Toolbar>(R.id.toolbar)
        setSupportActionBar(toolbar)
    }

    private fun setupButtons() {
        val voiceButton = findViewById<android.widget.ImageButton>(R.id.voice_button)
        val settingsButton = findViewById<android.widget.Button>(R.id.settings_button)

        voiceButton.setOnClickListener {
            // TODO: Implement direct voice command
        }

        settingsButton.setOnClickListener {
            TTSManager.speak(this, "Paramètres temporairement indisponibles")
        }
    }

    private fun showWelcomeIfNeeded() {
        if (WelcomeManager.shouldShowWelcome(this)) {
            val welcomeMessage = WelcomeManager.getWelcomeMessage()
            TTSManager.speak(this, welcomeMessage)
            Toast.makeText(this, welcomeMessage, Toast.LENGTH_LONG).show()
            WelcomeManager.markWelcomeShown(this)
        } else {
            TTSManager.speak(this, "MagicControl activé")
        }
    }

    private fun startWakeWordService() {
        val intent = Intent(this, WakeWordService::class.java)
        startService(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
    }
}
