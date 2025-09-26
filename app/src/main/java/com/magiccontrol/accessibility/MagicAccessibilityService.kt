package com.magiccontrol.accessibility

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.util.Log
import android.view.accessibility.AccessibilityEvent

class MagicAccessibilityService : AccessibilityService() {
    
    private val TAG = "MagicAccessibilityService"
    
    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "Service d'accessibilité connecté")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // Traitement des événements d'accessibilité si nécessaire
    }

    override fun onInterrupt() {
        Log.d(TAG, "Service d'accessibilité interrompu")
    }

    fun performGlobalBack() {
        performGlobalAction(GLOBAL_ACTION_BACK)
    }

    fun performGlobalHome() {
        performGlobalAction(GLOBAL_ACTION_HOME)
    }

    fun performGlobalRecents() {
        performGlobalAction(GLOBAL_ACTION_RECENTS)
    }

    fun performGlobalNotifications() {
        performGlobalAction(GLOBAL_ACTION_NOTIFICATIONS)
    }

    fun performGlobalQuickSettings() {
        performGlobalAction(GLOBAL_ACTION_QUICK_SETTINGS)
    }

    fun performSwipeGesture(startX: Float, startY: Float, endX: Float, endY: Float, duration: Long) {
        val path = Path().apply {
            moveTo(startX, startY)
            lineTo(endX, endY)
        }
        
        val gesture = GestureDescription.Builder()
            .addStroke(GestureDescription.StrokeDescription(path, 0, duration))
            .build()
            
        dispatchGesture(gesture, null, null)
    }
}