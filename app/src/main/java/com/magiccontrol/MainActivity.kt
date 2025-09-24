package com.magiccontrol

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.magiccontrol.service.WakeWordService
import com.magiccontrol.tts.TTSManager
import com.magiccontrol.ui.settings.SettingsActivity

class MainActivity : AppCompatActivity() {

    companion object {
        private const val RECORD_AUDIO_PERMISSION_CODE = 123
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Initialiser TTS
        TTSManager.initialize(this)

        // Configurer le bouton paramètres
        findViewById<android.widget.Button>(R.id.settings_button).setOnClickListener {
            val intent = Intent(this, SettingsActivity::class.java)
            startActivity(intent)
        }

        // Démarrer l'écoute permanente si permission accordée
        if (hasMicrophonePermission()) {
            startPermanentListening()
            showListeningIndicator(true)
        } else {
            requestMicrophonePermission()
        }
    }

    override fun onResume() {
        super.onResume()
        // Re-démarrer l'écoute quand l'activité revient au premier plan
        if (hasMicrophonePermission()) {
            startPermanentListening()
            showListeningIndicator(true)
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == RECORD_AUDIO_PERMISSION_CODE && grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            startPermanentListening()
            showListeningIndicator(true)
            TTSManager.speak("Écoute permanente activée. Dites ${getWakeWord()} pour commencer.")
        }
    }

    private fun hasMicrophonePermission(): Boolean {
        return ContextCompat.checkSelfPermission(this, android.Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestMicrophonePermission() {
        ActivityCompat.requestPermissions(this, arrayOf(android.Manifest.permission.RECORD_AUDIO), RECORD_AUDIO_PERMISSION_CODE)
    }

    private fun startPermanentListening() {
        val intent = Intent(this, WakeWordService::class.java)
        startService(intent)
    }

    private fun showListeningIndicator(show: Boolean) {
        findViewById<android.widget.TextView>(R.id.listening_indicator).visibility = 
            if (show) android.view.View.VISIBLE else android.view.View.GONE
    }

    private fun getWakeWord(): String {
        val prefs = com.magiccontrol.utils.PreferencesManager
        return prefs.getWakeWord(this)
    }
}
