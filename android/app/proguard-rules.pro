# --- Flutter engine -----------------------------------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# --- App (new namespace after the package rename) -----------------------
-keep class de.gbs_cidp.cidpbuddy.** { *; }

# --- flutter_local_notifications + Gson reflection ----------------------
-keep class com.google.gson.reflect.TypeToken
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.TypeVariable
-keep public class * implements java.lang.reflect.ParameterizedType
-keep public class * implements java.lang.reflect.GenericArrayType
-keep public class * implements java.lang.reflect.WildcardType
-keep class com.google.gson.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# --- WorkManager + workmanager plugin -----------------------------------
-keep class androidx.work.** { *; }
-keep class be.tramckrijte.workmanager.** { *; }
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.ListenableWorker
-keepclassmembers class * extends androidx.work.ListenableWorker {
    public <init>(android.content.Context,androidx.work.WorkerParameters);
}

# --- flutter_background_service -----------------------------------------
-keep class id.flutter.flutter_background_service.** { *; }
-keep class id.flutter.flutter_background_service_android.** { *; }

# --- sqlite3 native loader (drift) --------------------------------------
-keep class com.simolus3.sqlite3.** { *; }
-keep class com.tekartik.sqflite.** { *; }
-keep class io.requery.android.database.sqlite.** { *; }

# --- Google Sign-In / Drive / googleapis --------------------------------
-keep class com.google.api.** { *; }
-keep class com.google.api.client.** { *; }
-keep class com.google.api.services.** { *; }
-keep class com.google.auth.** { *; }
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-dontwarn com.google.api.client.**
-dontwarn org.apache.http.**
-dontwarn org.joda.time.**

# --- Google ML Kit (OCR) ------------------------------------------------
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }
-keep class com.google.android.gms.vision.** { *; }
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# --- audioplayers / icloud_storage / disable_battery_optimization -------
-keep class xyz.luan.audioplayers.** { *; }
-keep class com.iyiapps.icloudstorage.** { *; }
-keep class fluttercommunity.example.disablebatteryoptimizations.** { *; }

# Reduce noise from optional dependencies
-dontwarn javax.annotation.**
-dontwarn javax.lang.model.element.**
