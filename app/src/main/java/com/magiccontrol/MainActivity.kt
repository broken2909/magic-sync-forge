package com.magiccontrol

import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // JUSTE UN TOAST - RIEN D'AUTRE
        Toast.makeText(this, "Test minimal", Toast.LENGTH_LONG).show()
    }
}
