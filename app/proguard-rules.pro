# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep app classes
-keep class com.magiccontrol.** { *; }
-keepclassmembers class com.magiccontrol.** { *; }

# Ignore warnings
-dontwarn androidx.**