package com.solefate.aquawatertracker

import android.content.Context
import android.content.res.Configuration
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.LocalContext
import androidx.glance.action.ActionParameters
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.cornerRadius
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.text.FontWeight
import androidx.glance.action.actionParametersOf
import androidx.glance.unit.ColorProvider
import androidx.glance.currentState
import androidx.glance.state.GlanceStateDefinition
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition

private val amountKey = ActionParameters.Key<Int>("amount")

// ── Action Callback ────────────────────────────────────────────────
class AddHourlyWaterAction : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        val amount = parameters[amountKey] ?: 0
        if (amount <= 0) return

        val prefs = HomeWidgetPlugin.getData(context)
        val currentIntake = prefs.getInt("intake", 0)
        prefs.edit()
            .putInt("intake", currentIntake + amount)
            .putInt("last_added_ml", amount)
            .apply()

        // Refresh THIS widget immediately
        HourlyWidget().update(context, glanceId)

        // The background intent will eventually trigger updateWidget in Dart, 
        // which refreshes all widgets. For now, immediate feedback on this one is key.

        try {
            HomeWidgetBackgroundIntent.getBroadcast(
                context,
                Uri.parse("waterWidget://add/$amount")
            ).send()
        } catch (_: Exception) {}
    }
}

class UndoHourlyWaterAction : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        val prefs = HomeWidgetPlugin.getData(context)
        val lastAdded = prefs.getInt("last_added_ml", 0)

        if (lastAdded > 0) {
            val currentIntake = prefs.getInt("intake", 0)
            val newIntake = (currentIntake - lastAdded).coerceAtLeast(0)
            
            prefs.edit()
                .putInt("intake", newIntake)
                .putInt("last_added_ml", 0)
                .apply()

            HourlyWidget().update(context, glanceId)

            try {
                HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("waterWidget://undo")
                ).send()
            } catch (_: Exception) {}
        }
    }
}

class HourlyWidget : GlanceAppWidget() {
    override val stateDefinition: GlanceStateDefinition<*> = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val c = dynamicColors
            val state = currentState<HomeWidgetGlanceState>()
            val prefs = state.preferences

            val intake  = prefs.getInt("intake", 0)
            val goal    = prefs.getInt("goal", 2450).coerceAtLeast(1)
            val streak  = prefs.getInt("streak", 0)
            val nextReminder = prefs.getString("next_reminder", "--:--") ?: "--:--"
            
            // Percentage
            val progress = (intake.toFloat() / goal.toFloat()).coerceIn(0f, 1f)
            val pctStr   = String.format("%.0f", progress * 100)
            val remaining = (goal - intake).coerceAtLeast(0)

            // Dynamic Buckets
            val hourlyVals = prefs.getString("hourly_vals", "") ?: ""
            val hourlyLabels = prefs.getString("hourly_labels", "") ?: ""
            val valList = if (hourlyVals.isNotEmpty()) hourlyVals.split(",").map { it.toIntOrNull() ?: 0 } else emptyList()
            val labelList = if (hourlyLabels.isNotEmpty()) hourlyLabels.split(",") else emptyList()
            
            val maxVal = (valList.maxOrNull() ?: 500).coerceAtLeast(500).toFloat()

            Column(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .cornerRadius(24.dp)
                    .background(c.bg)
                    .padding(16.dp)
            ) {
                // Header
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Aqua - Hourly Intake",
                        maxLines = 1,
                        style = TextStyle(
                            color = c.textMain,
                            fontWeight = FontWeight.Bold,
                            fontSize = 15.sp
                        ),
                        modifier = GlanceModifier.defaultWeight()
                    )
                    Text(
                        text = "\uD83D\uDD25 $streak",
                        maxLines = 1,
                        style = TextStyle(
                            color = c.streak,
                            fontWeight = FontWeight.Bold,
                            fontSize = 14.sp
                        )
                    )
                    
                    val canUndo = prefs.getInt("last_added_ml", 0) > 0
                    if (canUndo) {
                        Spacer(modifier = GlanceModifier.width(8.dp))
                        Box(
                            modifier = GlanceModifier
                                .clickable(actionRunCallback<UndoHourlyWaterAction>())
                                .cornerRadius(8.dp)
                                .background(c.card)
                                .padding(horizontal = 8.dp, vertical = 4.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text("↺", style = TextStyle(color = c.primary, fontWeight = FontWeight.Bold, fontSize = 12.sp))
                        }
                    }
                }

                Spacer(modifier = GlanceModifier.height(12.dp))

                // Bar Chart Section
                if (valList.isNotEmpty()) {
                    Row(
                        modifier = GlanceModifier.fillMaxWidth().defaultWeight(),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalAlignment = Alignment.Bottom
                    ) {
                        valList.forEachIndexed { idx, v ->
                            val barHeight = (v.toFloat() / maxVal * 60f).coerceAtLeast(4f).dp
                            val label = labelList.getOrNull(idx) ?: "?"

                            Column(
                                horizontalAlignment = Alignment.CenterHorizontally,
                                verticalAlignment = Alignment.Bottom,
                                modifier = GlanceModifier.defaultWeight()
                            ) {
                                if (v > 0) {
                                    Text(
                                        text = "$v",
                                        maxLines = 1,
                                        style = TextStyle(
                                            color = c.textSub,
                                            fontSize = 9.sp,
                                            fontWeight = FontWeight.Bold
                                        )
                                    )
                                    Spacer(modifier = GlanceModifier.height(2.dp))
                                }
                                // Bar
                                Box(
                                    modifier = GlanceModifier
                                        .width(18.dp)
                                        .height(barHeight)
                                        .cornerRadius(4.dp)
                                        .background(if (v > 0) c.primary else c.card)
                                ) {}
                                Spacer(modifier = GlanceModifier.height(4.dp))
                                // Label
                                Text(
                                    text = label,
                                    maxLines = 1,
                                    style = TextStyle(
                                        color = c.textSub,
                                        fontSize = 9.sp,
                                        fontWeight = FontWeight.Medium
                                    )
                                )
                            }
                        }
                    }
                } else {
                    Box(
                        modifier = GlanceModifier.fillMaxWidth().defaultWeight(),
                        contentAlignment = Alignment.Center
                    ) {
                        Text("No logs today", style = TextStyle(color = c.textSub, fontSize = 12.sp))
                    }
                }

                Spacer(modifier = GlanceModifier.height(12.dp))

                // Status info
                Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.Bottom) {
                    Column(modifier = GlanceModifier.defaultWeight()) {
                        Row(verticalAlignment = Alignment.Bottom) {
                            Text(
                                text = "$intake",
                                style = TextStyle(color = c.textMain, fontWeight = FontWeight.Bold, fontSize = 20.sp)
                            )
                            Text(
                                text = " / $goal ml",
                                style = TextStyle(color = c.textSub, fontWeight = FontWeight.Medium, fontSize = 12.sp),
                                modifier = GlanceModifier.padding(bottom = 3.dp, start = 4.dp)
                            )
                        }
                        Spacer(modifier = GlanceModifier.height(4.dp))
                        Text(
                            text = "Next: $nextReminder",
                            style = TextStyle(color = c.textSub, fontWeight = FontWeight.Medium, fontSize = 11.sp)
                        )
                    }

                    Column(horizontalAlignment = Alignment.End) {
                        Text(
                            text = "$pctStr%",
                            style = TextStyle(color = c.primary, fontWeight = FontWeight.Bold, fontSize = 18.sp)
                        )
                        Spacer(modifier = GlanceModifier.height(4.dp))
                        Text(
                            text = "${remaining}ml left",
                            style = TextStyle(color = c.textSub, fontWeight = FontWeight.Medium, fontSize = 11.sp)
                        )
                    }
                }

                Spacer(modifier = GlanceModifier.height(10.dp))

                // Quick add buttons
                Row(modifier = GlanceModifier.fillMaxWidth()) {
                    listOf(100, 250, 300, 500).forEachIndexed { i, amt ->
                        if (i > 0) Spacer(modifier = GlanceModifier.width(6.dp))
                        Box(
                            modifier = GlanceModifier
                                .defaultWeight()
                                .clickable(actionRunCallback<AddHourlyWaterAction>(actionParametersOf(amountKey to amt)))
                                .cornerRadius(10.dp)
                                .background(c.card)
                                .padding(vertical = 8.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = "+$amt",
                                style = TextStyle(color = c.primary, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                            )
                        }
                    }
                }
            }
        }
    }
}
