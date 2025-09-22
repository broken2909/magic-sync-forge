package com.magiccontrol.command
import android.content.Context
import com.magiccontrol.system.SystemIntegration
object CommandProcessor {
    fun execute(context: Context, command: String) {
        SystemIntegration.handleSystemCommand(context, command)
    }
}
