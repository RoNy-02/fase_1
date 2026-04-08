# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.core.** { *; }

# Firebase Messaging
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.android.gms.internal.** { *; }

# Google Play Core (Play Split Install)
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }

# Timezone
-keep class net.time4j.** { *; }
-keep class org.threeten.** { *; }

# Preserve native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep generated plugin registrant
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep R files
-keepclassmembers class **.R$* {
    public static <fields>;
}
