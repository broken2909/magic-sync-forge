package com.magiccontrol

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.magiccontrol.utils.FirstLaunchWelcome

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // Activation du message vocal de bienvenue au premier lancement
        FirstLaunchWelcome.playWelcomeIfFirstLaunch(this)
    }
}
