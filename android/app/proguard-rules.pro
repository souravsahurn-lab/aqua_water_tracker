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

# ── Jetpack Glance App Widgets (keep ALL widgets + receivers + actions) ──
-keep class * extends androidx.glance.appwidget.GlanceAppWidget { *; }
-keep class * extends androidx.glance.appwidget.GlanceAppWidgetReceiver { *; }
-keep class * implements androidx.glance.appwidget.action.ActionCallback { *; }

# Explicit keep for every widget class (belt-and-suspenders for R8 full mode)
-keep class com.solefate.aquawatertracker.WaterWidget { *; }
-keep class com.solefate.aquawatertracker.WaterWidgetReceiver { *; }
-keep class com.solefate.aquawatertracker.AddWaterAction { *; }
-keep class com.solefate.aquawatertracker.UndoWaterAction { *; }

-keep class com.solefate.aquawatertracker.HourlyWidget { *; }
-keep class com.solefate.aquawatertracker.HourlyWidgetReceiver { *; }
-keep class com.solefate.aquawatertracker.AddHourlyWaterAction { *; }
-keep class com.solefate.aquawatertracker.UndoHourlyWaterAction { *; }

-keep class com.solefate.aquawatertracker.WeeklyWidget { *; }
-keep class com.solefate.aquawatertracker.WeeklyWidgetReceiver { *; }
-keep class com.solefate.aquawatertracker.AddWeeklyWaterAction { *; }
-keep class com.solefate.aquawatertracker.UndoWeeklyWaterAction { *; }

-keep class com.solefate.aquawatertracker.BottleWidget { *; }
-keep class com.solefate.aquawatertracker.BottleWidgetReceiver { *; }
-keep class com.solefate.aquawatertracker.AddBottleWaterAction { *; }
-keep class com.solefate.aquawatertracker.UndoBottleWaterAction { *; }

-keep class com.solefate.aquawatertracker.GridWidget { *; }
-keep class com.solefate.aquawatertracker.GridWidgetReceiver { *; }
-keep class com.solefate.aquawatertracker.AddGridWaterAction { *; }
-keep class com.solefate.aquawatertracker.UndoGridWaterAction { *; }

# Keep shared WidgetColors data class
-keep class com.solefate.aquawatertracker.WidgetColors { *; }

# ── Flutter In-App Purchase ──
-keep class com.android.billingclient.api.** { *; }

# ── Google Mobile Ads ──
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.mediation.** { *; }
-keep class com.google.android.gms.internal.ads.** { *; }
-dontwarn com.google.android.gms.ads.**
-dontwarn com.google.ads.mediation.**

# ── Metadata and Resources ──
-keepattributes Signature, *Annotation*, EnclosingMethod, InnerClasses
-keep class com.solefate.aquawatertracker.** { *; }

