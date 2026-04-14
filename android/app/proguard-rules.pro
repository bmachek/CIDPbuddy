# Flutter Local Notifications ProGuard Rules
# Required to prevent Gson from stripping type information in release builds

-keep class com.google.gson.reflect.TypeToken
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.TypeVariable
-keep public class * implements java.lang.reflect.ParameterizedType
-keep public class * implements java.lang.reflect.GenericArrayType
-keep public class * implements java.lang.reflect.WildcardType
-keep class com.google.gson.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.bm.igkeeper.igkeeper.** { *; }
