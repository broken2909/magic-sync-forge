package com.magiccontrol

import android.app.Application
import android.content.Context

class MagicControlApplication : Application() {

    companion object {
        lateinit var instance: MagicControlApplication
            private set
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
    }

    fun getAppContext(): Context = applicationContext
}