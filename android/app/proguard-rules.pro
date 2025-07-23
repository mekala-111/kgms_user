# Razorpay
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Keep all classes and their members
-keepclassmembers class * {
    *;
}

# Don't warn about missing ProGuard annotations
-dontwarn proguard.annotation.**

# General Flutter/Dart optimizations
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**