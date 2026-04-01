package com.solefate.aquawatertracker

import android.content.Context
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.ActionParameters
import androidx.glance.action.actionParametersOf
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.provideContent
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.LinearProgressIndicator
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.updateAll
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
import androidx.glance.LocalSize
import androidx.glance.currentState
import androidx.glance.state.GlanceStateDefinition
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition

private val amountKey = ActionParameters.Key<Int>("amount")

// ── Action Callbacks ────────────────────────────────────────────
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
        
        val lastStack = prefs.getString("widget_add_stack", "") ?: ""
        val newStack = if (lastStack.isEmpty()) "$amount" else "$amount,$lastStack"

        prefs.edit()
            .putInt("intake", currentIntake + amount)
            .putInt("last_added_ml", amount)
            .putString("widget_add_stack", newStack)
            .apply()

        // Instant redraw for this widget + WorkManager syncs the rest
        WidgetUpdateHelper.scheduleUpdate(context) {
            HourlyWidget().updateAll(context)
        }

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

        val stackStr = prefs.getString("widget_add_stack", "") ?: ""
        if (stackStr.isEmpty()) return
        
        val stack = stackStr.split(",").toMutableList()
        val lastAdded = stack.removeAt(0).toIntOrNull() ?: 0
        if (lastAdded <= 0) return
        
        val newStackStr = stack.joinToString(",")
        val nextAdded = if (stack.isNotEmpty()) stack[0].toIntOrNull() ?: 0 else 0

        val currentIntake = prefs.getInt("intake", 0)
        val newIntake = (currentIntake - lastAdded).coerceAtLeast(0)

        prefs.edit()
            .putInt("intake", newIntake)
            .putInt("last_added_ml", nextAdded)
            .putString("widget_add_stack", newStackStr)
            .apply()

        WidgetUpdateHelper.scheduleUpdate(context) {
            HourlyWidget().updateAll(context)
        }

        try {
            HomeWidgetBackgroundIntent.getBroadcast(
                context,
                Uri.parse("waterWidget://undo")
            ).send()
        } catch (_: Exception) {}
    }
}

// ── Widget ──────────────────────────────────────────────────────
class HourlyWidget : GlanceAppWidget() {
    override val sizeMode = SizeMode.Exact
    override val stateDefinition: GlanceStateDefinition<*> = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val c = dynamicColors
            val completedColor = ColorProvider(Color(0xFF22C55E))
            val size = LocalSize.current

            val state = currentState<HomeWidgetGlanceState>()
            val prefs = state.preferences

            val isPremium = prefs.getBoolean("is_premium", false)
            if (!isPremium) {
                Box(
                    modifier = GlanceModifier.fillMaxSize().cornerRadius(24.dp).background(c.bg).padding(16.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(text = "🔒", style = TextStyle(fontSize = 28.sp))
                        Spacer(modifier = GlanceModifier.height(8.dp))
                        Text(text = "Aqua Pro Required", style = TextStyle(color = c.textMain, fontWeight = FontWeight.Bold, fontSize = 14.sp))
                        Spacer(modifier = GlanceModifier.height(4.dp))
                        Text(text = "Upgrade to unlock widgets", style = TextStyle(color = c.textSub, fontSize = 11.sp))
                    }
                }
                return@provideContent
            }

            val intake  = prefs.getInt("intake", 0)
            val goal    = prefs.getInt("goal", 2450).coerceAtLeast(1)
            val unit = prefs.getString("volume_unit", "ml") ?: "ml"
            val streak  = prefs.getInt("streak", 0)
            val nextRem = prefs.getString("next_reminder", "--:--") ?: "--:--"
            val lastAdded = prefs.getInt("last_added_ml", 0)

            val progress  = (intake.toFloat() / goal.toFloat()).coerceIn(0f, 1f)
            val pctStr    = String.format("%.0f", progress * 100)
            val isCompleted = intake >= goal

            // Parse hourly data
            val valsStr   = prefs.getString("hourly_vals", "") ?: ""
            val labelsStr = prefs.getString("hourly_labels", "") ?: ""
            var vals = if (valsStr.isNotEmpty()) valsStr.split(",").map { it.toIntOrNull() ?: 0 } else emptyList()
            var labels = if (labelsStr.isNotEmpty()) labelsStr.split(",") else emptyList()

            if (vals.isEmpty() || labels.isEmpty()) {
                labels = listOf("7-9", "9-11", "11-1", "1-3", "3-5", "5-7", "7-9")
                vals = List(labels.size) { 0 }
            }
            val goalFloat = goal.toFloat().coerceAtLeast(1f)

            Column(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .cornerRadius(24.dp)
                    .background(c.bg)
                    .padding(16.dp)
            ) {
                // ── Header ──
                Row(
                    modifier = GlanceModifier.fillMaxWidth().height(28.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Aqua — Hourly",
                        maxLines = 1,
                        style = TextStyle(
                            color = c.textMain,
                            fontWeight = FontWeight.Bold,
                            fontSize = 14.sp
                        ),
                        modifier = GlanceModifier.defaultWeight()
                    )
                    // Undo button (pill style)
                    if (lastAdded > 0) {
                        Box(
                            modifier = GlanceModifier
                                .clickable(actionRunCallback<UndoHourlyWaterAction>())
                                .cornerRadius(12.dp)
                                .background(c.card)
                                .padding(horizontal = 8.dp, vertical = 4.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = "↩ Undo",
                                maxLines = 1,
                                style = TextStyle(
                                    color = c.textSub,
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 10.sp
                                )
                            )
                        }
                    }
                    Spacer(modifier = GlanceModifier.width(6.dp))
                    Text(
                        text = "\uD83D\uDD25 $streak",
                        maxLines = 1,
                        style = TextStyle(
                            color = c.streak,
                            fontWeight = FontWeight.Bold,
                            fontSize = 11.sp
                        )
                    )
                }

                Spacer(modifier = GlanceModifier.defaultWeight())

                // ── Bar Chart ──
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    verticalAlignment = Alignment.Bottom
                ) {
                    val barCount = vals.size.coerceAtMost(labels.size)

                    for (i in 0 until barCount) {
                        Column(
                            modifier = GlanceModifier
                                .defaultWeight()
                                .padding(horizontal = 3.dp),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalAlignment = Alignment.Bottom
                        ) {
                            val v = vals[i]
                            val rawDynMaxH = (size.height.value - 158f).coerceAtLeast(10f)
                            val dynMaxH = (rawDynMaxH * 0.9f).coerceAtLeast(10f)

                            // Scale bar height against the TOTAL daily goal so bars fill progressively
                            val barHGauge = (v.toFloat() / goalFloat * dynMaxH).coerceIn(0f, dynMaxH)
                            val barH = if (v > 0) barHGauge.coerceAtLeast(4f) else 0f

                            // Use neutral primary color for all filled bars
                            val barColor = if (v > 0) c.primary else c.card

                            // Show intake value above bar if it exists
                            if (v > 0) {
                                val displayVal = if (v >= 1000) {
                                    String.format("%.1fk", v / 1000f)
                                } else {
                                    "$v"
                                }
                                Text(
                                    text = displayVal,
                                    maxLines = 1,
                                    style = TextStyle(
                                        color = if (v >= goal) completedColor else c.textSub,
                                        fontSize = 8.sp,
                                        fontWeight = FontWeight.Bold
                                    )
                                )
                                Spacer(modifier = GlanceModifier.height(3.dp))
                            }

                            Box(
                                modifier = GlanceModifier
                                    .fillMaxWidth()
                                    .height(dynMaxH.dp)
                                    .cornerRadius(24.dp)
                                    .background(c.card),
                                contentAlignment = Alignment.BottomCenter
                            ) {
                                if (v > 0) {
                                    Box(
                                        modifier = GlanceModifier
                                            .fillMaxWidth()
                                            .height(barH.dp)
                                            .cornerRadius(24.dp)
                                            .background(barColor)
                                    ) {}
                                }
                            }
                            Spacer(modifier = GlanceModifier.height(6.dp))
                            Text(
                                text = if (i < labels.size) labels[i] else "",
                                maxLines = 1,
                                style = TextStyle(
                                    color = if (v > 0) c.textMain else c.textSub,
                                    fontWeight = if (v > 0) FontWeight.Bold else FontWeight.Medium,
                                    fontSize = 8.sp
                                )
                            )
                        }
                    }
                }

                Spacer(modifier = GlanceModifier.defaultWeight())

                // ── Status row with progress bar ──
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "$intake/$goal $unit",
                        maxLines = 1,
                        style = TextStyle(
                            color = if (isCompleted) completedColor else c.textMain,
                            fontWeight = FontWeight.Bold,
                            fontSize = 11.sp
                        )
                    )
                    Spacer(modifier = GlanceModifier.width(6.dp))
                    LinearProgressIndicator(
                        progress = progress,
                        modifier = GlanceModifier
                            .defaultWeight()
                            .height(6.dp)
                            .cornerRadius(3.dp),
                        color = if (isCompleted) completedColor else c.primary,
                        backgroundColor = c.card
                    )
                    Spacer(modifier = GlanceModifier.width(6.dp))
                    Text(
                        text = "$pctStr%",
                        maxLines = 1,
                        style = TextStyle(
                            color = if (isCompleted) completedColor else c.textSub,
                            fontWeight = FontWeight.Bold,
                            fontSize = 10.sp
                        )
                    )
                }

                Spacer(modifier = GlanceModifier.height(6.dp))

                // ── Next reminder ──
                Row(modifier = GlanceModifier.fillMaxWidth()) {
                    Text(
                        text = "🔔 $nextRem",
                        maxLines = 1,
                        style = TextStyle(
                            color = c.textSub,
                            fontWeight = FontWeight.Medium,
                            fontSize = 10.sp
                        )
                    )
                }

                Spacer(modifier = GlanceModifier.height(8.dp))

                // ── Quick-add Buttons ──
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    listOf(100, 250, 300, 500).forEachIndexed { index, amt ->
                        if (index > 0) Spacer(modifier = GlanceModifier.width(4.dp))
                        Box(
                            modifier = GlanceModifier
                                .defaultWeight()
                                .clickable(
                                    actionRunCallback<AddHourlyWaterAction>(
                                        actionParametersOf(amountKey to amt)
                                    )
                                )
                                .cornerRadius(8.dp)
                                .background(c.card)
                                .padding(vertical = 8.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = "+$amt",
                                maxLines = 1,
                                style = TextStyle(
                                    color = c.primary,
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 11.sp
                                )
                            )
                        }
                    }
                }
            }
        }
    }
}

// ── Helper: Color by completion percentage ──────────────────────
private fun getCompletionColor(v: Int, g: Int): ColorProvider {
    val pct = if (g > 0) (v.toFloat() / g.toFloat() * 100) else 0f
    return when {
        pct >= 100 -> ColorProvider(Color(0xFF22C55E)) // Success (Green)
        pct >= 75 ->  ColorProvider(Color(0xFF4ADE80)) // Light Green
        pct >= 50 ->  ColorProvider(Color(0xFFFBBF24)) // Yellow
        pct >= 25 ->  ColorProvider(Color(0xFFF97316)) // Orange
        else ->       ColorProvider(Color(0xFFEF4444)) // Red
    }
}
