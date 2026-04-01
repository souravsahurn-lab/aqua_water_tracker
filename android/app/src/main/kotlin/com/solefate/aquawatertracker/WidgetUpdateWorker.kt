package com.solefate.aquawatertracker

import android.content.Context
import androidx.glance.appwidget.updateAll
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters

import android.net.Uri
import es.antonborri.home_widget.HomeWidgetBackgroundIntent

class WidgetUpdateWorker(
    private val context: Context,
    workerParams: WorkerParameters
) : CoroutineWorker(context, workerParams) {

    override suspend fun doWork(): Result {
        return try {
            WaterWidget().updateAll(context)
            HourlyWidget().updateAll(context)
            WeeklyWidget().updateAll(context)
            BottleWidget().updateAll(context)
            GridWidget().updateAll(context)

            // Also fire Dart sync so charts/hourly/weekly are fresh
            try {
                HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("waterWidget://sync")
                ).send()
            } catch (_: Exception) {}

            Result.success()
        } catch (_: Exception) {
            Result.retry()
        }
    }
}
