package com.solefate.aquawatertracker

import android.content.Context
import android.appwidget.AppWidgetManager
import androidx.compose.runtime.Composable
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
import androidx.glance.action.ActionParameters
import androidx.glance.action.actionParametersOf
import androidx.glance.action.clickable
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.updateAll
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import android.net.Uri

private val amountKey = ActionParameters.Key<Int>("amount")

class AddBottleWaterAction : ActionCallback {
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
            BottleWidget().updateAll(context)
        }

        try {
            HomeWidgetBackgroundIntent.getBroadcast(
                context,
                Uri.parse("waterWidget://add/$amount")
            ).send()
        } catch (_: Exception) {}
    }
}

class UndoBottleWaterAction : ActionCallback {
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
            BottleWidget().updateAll(context)
        }

        try {
            HomeWidgetBackgroundIntent.getBroadcast(
                context,
                Uri.parse("waterWidget://undo")
            ).send()
        } catch (_: Exception) {}
    }
}

class BottleWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = BottleWidget()

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        super.onUpdate(context, appWidgetManager, appWidgetIds)
        WidgetUpdateHelper.scheduleUpdate(context) {
            BottleWidget().updateAll(context)
        }
    }
}

class BottleWidget : GlanceAppWidget() {
    override val stateDefinition: GlanceStateDefinition<*> = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val c = dynamicColors
            val completedColor = ColorProvider(Color(0xFF22C55E))
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

            val intake = prefs.getInt("intake", 0)
            val goal = prefs.getInt("goal", 2450).coerceAtLeast(1)
            val unit = prefs.getString("volume_unit", "ml") ?: "ml"
            val streak = prefs.getInt("streak", 0)

            val progress = (intake.toFloat() / goal.toFloat()).coerceIn(0f, 1f)
            val pctStr = String.format("%.0f", progress * 100)
            val isCompleted = intake >= goal
            val intakeColor = if (isCompleted) completedColor else c.textMain

            Column(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .cornerRadius(24.dp)
                    .background(c.bg)
                    .padding(12.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // ── Header ──
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = GlanceModifier.defaultWeight()) {
                        Row(verticalAlignment = Alignment.Bottom) {
                            Text(
                                text = "$intake",
                                maxLines = 1,
                                style = TextStyle(
                                    color = intakeColor,
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 20.sp
                                )
                            )
                            Text(
                                text = "/$goal $unit",
                                maxLines = 1,
                                style = TextStyle(
                                    color = c.textSub,
                                    fontWeight = FontWeight.Medium,
                                    fontSize = 10.sp
                                ),
                                modifier = GlanceModifier.padding(bottom = 3.dp, start = 2.dp)
                            )
                        }
                        Text(
                            text = "$pctStr%  ·  \uD83D\uDD25 $streak",
                            maxLines = 1,
                            style = TextStyle(
                                color = c.textSub,
                                fontWeight = FontWeight.Medium,
                                fontSize = 10.sp
                            ),
                            modifier = GlanceModifier.padding(top = 2.dp)
                        )
                    }
                }

                Spacer(modifier = GlanceModifier.height(8.dp))

                // ── Bottle ──
                val bottleHeight = 80f
                Box(
                    modifier = GlanceModifier
                        .width(64.dp)
                        .height(bottleHeight.dp)
                        .cornerRadius(14.dp)
                        .background(c.card),
                    contentAlignment = Alignment.BottomCenter
                ) {
                    Box(
                        modifier = GlanceModifier
                            .fillMaxWidth()
                            .height((bottleHeight * progress).dp)
                            .cornerRadius(10.dp)
                            .background(if (isCompleted) completedColor else c.primary)
                    ) {}
                }

                Spacer(modifier = GlanceModifier.defaultWeight())

                // ── 2×2 Quick-add ──
                Column(modifier = GlanceModifier.fillMaxWidth()) {
                    Row(modifier = GlanceModifier.fillMaxWidth()) {
                        listOf(100, 250).forEachIndexed { i, amt ->
                            if (i > 0) Spacer(modifier = GlanceModifier.width(5.dp))
                            Box(
                                modifier = GlanceModifier
                                    .defaultWeight()
                                    .clickable(actionRunCallback<AddBottleWaterAction>(actionParametersOf(amountKey to amt)))
                                    .cornerRadius(8.dp)
                                    .background(c.card)
                                    .padding(vertical = 7.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = "+$amt",
                                    maxLines = 1,
                                    style = TextStyle(color = c.primary, fontWeight = FontWeight.Bold, fontSize = 12.sp)
                                )
                            }
                        }
                    }
                    Spacer(modifier = GlanceModifier.height(5.dp))
                    Row(modifier = GlanceModifier.fillMaxWidth()) {
                        listOf(300, 500).forEachIndexed { i, amt ->
                            if (i > 0) Spacer(modifier = GlanceModifier.width(5.dp))
                            Box(
                                modifier = GlanceModifier
                                    .defaultWeight()
                                    .clickable(actionRunCallback<AddBottleWaterAction>(actionParametersOf(amountKey to amt)))
                                    .cornerRadius(8.dp)
                                    .background(c.card)
                                    .padding(vertical = 7.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = "+$amt",
                                    maxLines = 1,
                                    style = TextStyle(color = c.primary, fontWeight = FontWeight.Bold, fontSize = 12.sp)
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}
