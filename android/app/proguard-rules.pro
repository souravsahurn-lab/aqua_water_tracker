-keep class com.dexterous.** { *; }
-keep class androidx.core.app.CoreComponentFactory { *; }

# Gson specific classes
-dontwarn sun.misc.**

# Application classes that will be serialized/deserialized over Gson
-keep class com.google.gson.examples.android.model.** { <fields>; }

# Prevent proguard from stripping interface information from TypeAdapter, TypeAdapterFactory,
# JsonSerializer, JsonDeserializer instances
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Prevent R8 from leaving Data object members always null
-keepclassmembers,allowobfuscation class * { @com.google.gson.annotations.SerializedName <fields>; }

# Retain generic signatures of TypeToken and its subclasses
-keep class * extends com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# ── Jetpack Glance App Widget ──
-keep class com.solefate.aquawatertracker.WaterWidget { *; }
-keep class com.solefate.aquawatertracker.WaterWidgetReceiver { *; }
-keep class com.solefate.aquawatertracker.AddWaterAction { *; }
-keep class * extends androidx.glance.appwidget.GlanceAppWidget { *; }
-keep class * extends androidx.glance.appwidget.GlanceAppWidgetReceiver { *; }
-keep class * implements androidx.glance.appwidget.action.ActionCallback { *; }

# ── home_widget plugin ──
-keep class es.antonborri.home_widget.** { *; }

