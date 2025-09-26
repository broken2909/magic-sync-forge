package com.magiccontrol.ui.components

import android.content.Context
import android.util.AttributeSet
import androidx.appcompat.widget.AppCompatImageView

class VoiceButtonView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : AppCompatImageView(context, attrs, defStyleAttr)
{
    // Classe vide pour l'instant - à implémenter
    init {
        // Initialisation du bouton vocal
        setImageResource(android.R.drawable.ic_btn_speak_now)
    }
}
