package com.solefate.aquawatertracker

import android.content.Context
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

object WidgetUpdateHelper {

    // Call this with the specific widget that was tapped
    // That widget redraws instantly via coroutine
    // All other widgets sync via WorkManager (battery-safe)
    fun scheduleUpdate(context: Context, triggerImmediate: (suspend () -> Unit)? = null) {

        // Layer 1 — instant redraw for the tapped widget only
        // This is fast because it's just one widget, not all 5
        if (triggerImmediate != null) {
            CoroutineScope(Dispatchers.Main).launch {
                try {
                    triggerImmediate()
                } catch (_: Exception) {}
            }
        }

        // Layer 2 — WorkManager syncs all widgets (battery-safe, coalesced)
        val request = OneTimeWorkRequestBuilder<WidgetUpdateWorker>()
            .build()

        WorkManager.getInstance(context).enqueueUniqueWork(
            "widget_update",
            ExistingWorkPolicy.REPLACE,
            request
        )
    }
}
