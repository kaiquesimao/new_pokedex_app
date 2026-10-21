# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Play In-App Updates ship via in_app_update (app-update). Flutter may still
# reference unused deferred-components Play Core stubs — suppress R8 noise.
-dontwarn com.google.android.play.core.**

# Firebase / Google
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable / Serializable helpers
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}
