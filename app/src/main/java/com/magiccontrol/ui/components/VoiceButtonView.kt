package com.magiccontrol.ui.components

import android.content.Context
import android.util.AttributeSet
import androidx.appcompat.widget.AppCompatImageView

class VoiceButtonView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : AppCompatImageView(context, attrs, defStyleAttr) {
    
    enum class State { IDLE, LISTENING, PROCESSING }
    
    fun setState(state: State) {
        when (state) {
            State.IDLE -> setImageResource(android.R.drawable.ic_btn_speak_now)
            State.LISTENING -> setImageResource(android.R.drawable.ic_media_play)
            State.PROCESSING -> setImageResource(android.R.drawable.ic_media_pause)
        }
    }
}
