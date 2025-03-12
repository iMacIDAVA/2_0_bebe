# Keep all classes from Agora SDK
-keep class io.agora.** { *; }

# Keep all classes from Stripe SDK
-keep class com.stripe.android.** { *; }
-keep class com.stripe.** { *; }
-keep class com.reactnativestripesdk.** { *; }

# Keep classes required for Java 8+ desugaring
-keep class com.google.devtools.build.android.desugar.runtime.** { *; }

# Keep other important AndroidX and Kotlin classes
-keep class com.google.** { *; }
-keep class androidx.** { *; }
-keep class kotlin.** { *; }

# General ProGuard rules to avoid stripping important methods
-dontwarn com.google.**
-dontwarn io.agora.**
-dontwarn com.stripe.**
-dontwarn kotlin.**

# Optimization rules (Optional, can be removed if issues persist)
-keepattributes Exceptions,InnerClasses,Signature,Deprecated,SourceFile,LineNumberTable,*Annotation*
-keepnames class * { *; }
