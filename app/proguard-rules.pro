# Configuration ProGuard pour MagicControl

# Conserver les classes Vosk
-keep class org.vosk.** { *; }
-keep class net.java.dev.jna.** { *; }

# Conserver les classes de modèle
-keepclassmembers class * {
    public <methods>;
}

# Conserver les classes de service
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver

# Conserver les activités
-keep public class * extends android.app.Activity

# Conserver les vues
-keepclassmembers class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
    public void set*(...);
}

# Conserver les callbacks
-keepclassmembers class * {
    void onClick*(...);
}

# Configuration Kotlin
-keep class kotlin.** { *; }
-keepclassmembers class **$WhenMappings {
    <fields>;
}
