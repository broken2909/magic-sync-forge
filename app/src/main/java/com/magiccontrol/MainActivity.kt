package com.magiccontrol

import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.magiccontrol.databinding.ActivityMainBinding
import com.magiccontrol.utils.WelcomeManager

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // TEST: Databinding seulement
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        // Juste un toast pour tester
        Toast.makeText(this, "Avec databinding", Toast.LENGTH_LONG).show()
        
        // Welcome simple
        if (WelcomeManager.shouldShowWelcome(this)) {
            val welcomeMessage = WelcomeManager.getWelcomeMessage()
            Toast.makeText(this, welcomeMessage, Toast.LENGTH_LONG).show()
            WelcomeManager.markWelcomeShown(this)
        }
    }
}
