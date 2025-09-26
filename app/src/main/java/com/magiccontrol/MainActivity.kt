package com.magiccontrol

import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.magiccontrol.utils.PreferencesManager
import com.magiccontrol.tts.TTSManager

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // Toast bref à chaque ouverture
        Toast.makeText(this, "MagicControl activé", Toast.LENGTH_SHORT).show()
        
        // Synthèse vocale uniquement à la première utilisation
        if (PreferencesManager.isFirstLaunch(this)) {
            TTSManager.speak(this, "Bienvenue dans MagicControl, votre assistant vocal offline") {
                // Une fois le message vocal terminé, marquer comme déjà lancé
                PreferencesManager.setFirstLaunchComplete(this@MainActivity)
            }
        }
    }
}
