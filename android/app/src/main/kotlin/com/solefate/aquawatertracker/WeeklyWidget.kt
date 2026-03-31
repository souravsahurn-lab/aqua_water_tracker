package com.solefate.aquawatertracker

import android.content.Context
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.provideContent
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
import androidx.glance.unit.ColorProvider
import androidx.glance.currentState
import androidx.glance.state.GlanceStateDefinition
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import androidx.glance.action.ActionParameters
import androidx.glance.action.actionParametersOf
import androidx.glance.action.clickable
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import android.net.Uri

private val amountKey = ActionParameters.Key<Int>("amount")

class AddWeeklyWaterAction : ActionCallback {
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

        WeeklyWidget().update(context, glanceId)

        try {
            HomeWidgetBackgroundIntent.getBroadcast(
                context,
                Uri.parse("waterWidget://add/$amount")
            ).send()
        } catch (_: Exception) {}
    }
}

class UndoWeeklyWaterAction : ActionCallback {
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

            WeeklyWidget().update(context, glanceId)

            try {
                HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("waterWidget://undo")
                ).send()
            } catch (_: Exception) {}
        }
    }
}

class WeeklyWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = WeeklyWidget()
}

class WeeklyWidget : GlanceAppWidget() {
    override val stateDefinition: GlanceStateDefinition<*> = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val c = dynamicColors
            val completedColor = ColorProvider(Color(0xFF22C55E)) // Green for completed
            val state = currentState<HomeWidgetGlanceState>()
            val prefs = state.preferences

            val goal = prefs.getInt("goal", 2450).coerceAtLeast(1)
            val intake = prefs.getInt("intake", 0)
            val streak = prefs.getInt("streak", 0)
            val nextReminder = prefs.getString("next_reminder", "--:--") ?: "--:--"

            val progress = (intake.toFloat() / goal.toFloat()).coerceIn(0f, 1f)
            val pctStr   = String.format("%.0f", progress * 100)
            val remaining = (goal - intake).coerceAtLeast(0)

            // Weekly data
            val weeklyValsStr = prefs.getString("weekly_vals", "") ?: ""
            val weeklyLabelsTopStr = prefs.getString("weekly_labels_top", "") ?: ""
            val weeklyLabelsBottomStr = prefs.getString("weekly_labels_bottom", "") ?: ""

            val valList = if (weeklyValsStr.isNotEmpty()) weeklyValsStr.split(",").map { it.toIntOrNull() ?: 0 } else emptyList()
            val labelTopList = if (weeklyLabelsTopStr.isNotEmpty()) weeklyLabelsTopStr.split(",") else emptyList()
            val labelBottomList = if (weeklyLabelsBottomStr.isNotEmpty()) weeklyLabelsBottomStr.split(",") else emptyList()

            // Header stats
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
                        text = "Weekly Hydration",
                        maxLines = 1,
                        style = TextStyle(color = c.textMain, fontWeight = FontWeight.Bold, fontSize = 15.sp),
                        modifier = GlanceModifier.defaultWeight()
                    )
                    Text(
                        text = "\uD83D\uDD25 $streak",
                        maxLines = 1,
                        style = TextStyle(color = c.streak, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                    )
                    
                    val canUndo = prefs.getInt("last_added_ml", 0) > 0
                    if (canUndo) {
                        Spacer(modifier = GlanceModifier.width(8.dp))
                        Box(
                            modifier = GlanceModifier
                                .clickable(actionRunCallback<UndoWeeklyWaterAction>())
                                .cornerRadius(8.dp)
                                .background(c.card)
                                .padding(horizontal = 8.dp, vertical = 4.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text("↺", style = TextStyle(color = c.primary, fontWeight = FontWeight.Bold, fontSize = 12.sp))
                        }
                    }
                }

                Spacer(modifier = GlanceModifier.height(10.dp))

                // Chart
                if (valList.isNotEmpty()) {
                    Row(
                        modifier = GlanceModifier.fillMaxWidth().defaultWeight(),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalAlignment = Alignment.Bottom
                    ) {
                        for (i in 0 until 7) {
                            val v = valList.getOrNull(i) ?: 0
                            val labelTop = labelTopList.getOrNull(i) ?: ""
                            val labelBottom = labelBottomList.getOrNull(i) ?: ""
                            
                            val isCompleted = v >= goal
                            val barColor = if (isCompleted) completedColor else c.primary

                            // Cap drawing height at 100%
                            val visualGoal = goal.toFloat()
                            val fraction = (v.toFloat() / visualGoal).coerceIn(0f, 1f)
                            val barHeight = (fraction * 45f).coerceAtLeast(4f).dp

                            // Compress values like 2450 -> 2.4k to save width space 
                            val kVal = if (v >= 1000) String.format("%.1f", v / 1000f) + "k" else v.toString()
                            val kGoal = if (goal >= 1000) String.format("%.1f", goal / 1000f) + "k" else goal.toString()
                            
                            Column(
                                horizontalAlignment = Alignment.CenterHorizontally,
                                verticalAlignment = Alignment.Bottom,
                                modifier = GlanceModifier.defaultWeight()
                            ) {
                                // Intake / Goal text stacked
                                Text(
                                    text = kVal,
                                    maxLines = 1,
                                    style = TextStyle(color = c.textSub, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                                )
                                Text(
                                    text = "/$kGoal",
                                    maxLines = 1,
                                    style = TextStyle(color = c.textSub, fontSize = 9.sp, fontWeight = FontWeight.Medium)
                                )
                                Spacer(modifier = GlanceModifier.height(4.dp))
                                
                                // Bar
                                Box(
                                    modifier = GlanceModifier
                                        .width(18.dp)
                                        .height(barHeight)
                                        .cornerRadius(4.dp)
                                        .background(if (v > 0) barColor else c.card)
                                ) {}
                                Spacer(modifier = GlanceModifier.height(4.dp))
                                
                                // Day Name
                                Text(
                                    text = labelTop,
                                    maxLines = 1,
                                    style = TextStyle(color = c.textMain, fontSize = 11.sp, fontWeight = FontWeight.Medium)
                                )
                                // Day Date
                                Text(
                                    text = labelBottom,
                                    maxLines = 1,
                                    style = TextStyle(color = c.textSub, fontSize = 10.sp, fontWeight = FontWeight.Normal)
                                )
                            }
                        }
                    }
                } else {
                    Box(
                        modifier = GlanceModifier.fillMaxWidth().defaultWeight(),
                        contentAlignment = Alignment.Center
                    ) {
                        Text("No logs this week", style = TextStyle(color = c.textSub, fontSize = 12.sp))
                    }
                }

                Spacer(modifier = GlanceModifier.height(10.dp))

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
                                .clickable(actionRunCallback<AddWeeklyWaterAction>(actionParametersOf(amountKey to amt)))
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

