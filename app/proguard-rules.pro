# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep Vosk classes
-keep class org.vosk.** { *; }
-keepclassmembers class org.vosk.** { *; }

# Keep JNA classes
-keep class com.sun.jna.** { *; }
-keepclassmembers class com.sun.jna.** { *; }

# Keep app classes
-keep class com.magiccontrol.** { *; }
-keepclassmembers class com.magiccontrol.** { *; }

# Ignore warnings
-dontwarn org.vosk.**
-dontwarn com.sun.jna.**
