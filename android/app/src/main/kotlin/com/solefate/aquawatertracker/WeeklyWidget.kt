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
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.provideContent
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.LinearProgressIndicator
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
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

// ── Helper: Color by completion percentage ──────────────────────
// <25% = red, 25-50% = orange, 50-75% = yellow, >=75% = green, 100% = bright green
private fun getCompletionColor(intake: Int, goal: Int): ColorProvider {
    if (goal <= 0) return ColorProvider(Color(0xFFEF4444))
    val pct = (intake.toFloat() / goal.toFloat() * 100f)
    return when {
        pct >= 100f -> ColorProvider(Color(0xFF22C55E))  // bright green — goal met
        pct >= 75f  -> ColorProvider(Color(0xFF4ADE80))  // green
        pct >= 50f  -> ColorProvider(Color(0xFFFBBF24))  // yellow
        pct >= 25f  -> ColorProvider(Color(0xFFF97316))  // orange
        else        -> ColorProvider(Color(0xFFEF4444))  // red
    }
}

// ── Widget ──────────────────────────────────────────────────────
class WeeklyWidget : GlanceAppWidget() {
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
            val streak  = prefs.getInt("streak", 0)
            val nextRem = prefs.getString("next_reminder", "--:--") ?: "--:--"
            val lastAdded = prefs.getInt("last_added_ml", 0)

            val progress = (intake.toFloat() / goal.toFloat()).coerceIn(0f, 1f)
            val pctStr   = String.format("%.0f", progress * 100)
            val isCompleted = intake >= goal

            // Parse weekly data
            val valsStr = prefs.getString("weekly_vals", "") ?: ""
            val labelsTopStr = prefs.getString("weekly_labels_top", "") ?: ""
            
            var vals = if (valsStr.isNotEmpty()) valsStr.split(",").map { it.toIntOrNull() ?: 0 } else emptyList()
            var labelsTop = if (labelsTopStr.isNotEmpty()) labelsTopStr.split(",") else emptyList()
            
            if (vals.isEmpty() || labelsTop.isEmpty()) {
                labelsTop = listOf("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
                vals = List(labelsTop.size) { 0 }
            }
            val goalFloat = goal.toFloat().coerceAtLeast(1f)

            // Parse weekly goals
            val goalsStr = prefs.getString("weekly_goals", "") ?: ""
            var goals = if (goalsStr.isNotEmpty()) {
                goalsStr.split(",").map { it.toIntOrNull() ?: goal }
            } else {
                List(vals.size) { goal }
            }

            Column(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .cornerRadius(24.dp)
                    .background(c.bg)
                    .padding(16.dp)
            ) {
                // ── Header row ──
                Row(
                    modifier = GlanceModifier.fillMaxWidth().height(28.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Aqua — Weekly Intake",
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
                                .clickable(actionRunCallback<UndoWeeklyWaterAction>())
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

                // ── Bar Chart (color-coded by completion) ──
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    verticalAlignment = Alignment.Bottom
                ) {
                    val barCount = vals.size.coerceAtMost(labelsTop.size)
                    for (i in 0 until barCount) {
                        val v = vals[i]
                        val g = if (i < goals.size) goals[i].coerceAtLeast(1) else goal
                        val gFloat = g.toFloat()

                        Column(
                            modifier = GlanceModifier
                                .defaultWeight()
                                .padding(horizontal = 3.dp),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalAlignment = Alignment.Bottom
                        ) {
                            val rawDynMaxH = (size.height.value - 158f).coerceAtLeast(10f)
                            val dynMaxH = (rawDynMaxH * 0.9f).coerceAtLeast(10f)
                            val barHGauge = (v.toFloat() / gFloat * dynMaxH).coerceIn(0f, dynMaxH)
                            val barH = if (v > 0) barHGauge.coerceAtLeast(8f) else 0f

                            val isTargetMet = v >= g
                            val barColor = if (v > 0) {
                                getCompletionColor(v, g)
                            } else {
                                c.card
                            }

                            // Show intake above bar (short form for space)
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
                                        color = if (isTargetMet) completedColor else c.textSub,
                                        fontSize = 7.sp,
                                        fontWeight = FontWeight.Bold
                                    )
                                )
                                Spacer(modifier = GlanceModifier.height(2.dp))
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
                            // Day label
                            Text(
                                text = if (i < labelsTop.size) labelsTop[i] else "",
                                maxLines = 1,
                                style = TextStyle(
                                    color = if (i == barCount - 1) c.textMain else c.textSub,
                                    fontWeight = if (i == barCount - 1) FontWeight.Bold else FontWeight.Medium,
                                    fontSize = 9.sp
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
                        text = "$intake/$goal ml",
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
                                    actionRunCallback<AddWeeklyWaterAction>(
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
