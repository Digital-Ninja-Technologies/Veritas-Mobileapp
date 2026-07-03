-keep class io.flutter.** { *; }
-keep class com.google.** { *; }
-dontwarn io.flutter.embedding.**
# javax.lang.model is a javac/APT-only type referenced by
# com.google.errorprone.annotations at SOURCE/CLASS retention — it's never
# needed at runtime, so R8 just needs to stop warning about it missing.
-dontwarn javax.lang.model.element.Modifier
