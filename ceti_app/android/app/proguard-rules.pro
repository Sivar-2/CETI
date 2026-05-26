# Proguard rules for CETI App Production Build

# Firebase SDKs Protection
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-keep class io.flutter.plugins.firebase.** { *; }

# NFC Manager Protection
-keep class tech.nfc.manager.** { *; }
-keepclassmembers class tech.nfc.manager.** { *; }

# Flutter Engine
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Preserve annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
