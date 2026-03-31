package com.solefate.aquawatertracker

import android.content.Context
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
        prefs.edit()
            .putInt("intake", currentIntake + amount)
            .putInt("last_added_ml", amount)
            .apply()

        BottleWidget().update(context, glanceId)

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
        val lastAdded = prefs.getInt("last_added_ml", 0)

        if (lastAdded > 0) {
            val currentIntake = prefs.getInt("intake", 0)
            val newIntake = (currentIntake - lastAdded).coerceAtLeast(0)
            
            prefs.edit()
                .putInt("intake", newIntake)
                .putInt("last_added_ml", 0)
                .apply()

            BottleWidget().update(context, glanceId)

            try {
                HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("waterWidget://undo")
                ).send()
            } catch (_: Exception) {}
        }
    }
}

class BottleWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = BottleWidget()
}

class BottleWidget : GlanceAppWidget() {
    override val stateDefinition: GlanceStateDefinition<*> = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val c = dynamicColors
            val completedColor = ColorProvider(Color(0xFF22C55E)) // Green for completed
            val state = currentState<HomeWidgetGlanceState>()
            val prefs = state.preferences

            val intake = prefs.getInt("intake", 0)
            val goal = prefs.getInt("goal", 2450).coerceAtLeast(1)
            val streak = prefs.getInt("streak", 0)
            val nextReminder = prefs.getString("next_reminder", "--:--") ?: "--:--"

            val progress = (intake.toFloat() / goal.toFloat()).coerceIn(0f, 1f)
            val isCompleted = intake >= goal

            Column(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .cornerRadius(24.dp)
                    .background(c.bg)
                    .padding(12.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Header (Intake/Goal & Streak)
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = GlanceModifier.defaultWeight()) {
                        Text(
                            text = "$intake",
                            maxLines = 1,
                            style = TextStyle(color = c.textMain, fontWeight = FontWeight.Bold, fontSize = 18.sp)
                        )
                        Text(
                            text = "/ $goal ml",
                            maxLines = 1,
                            style = TextStyle(color = c.textSub, fontWeight = FontWeight.Medium, fontSize = 11.sp)
                        )
                        Text(
                            text = "🔔 $nextReminder",
                            maxLines = 1,
                            style = TextStyle(color = c.primary, fontWeight = FontWeight.Medium, fontSize = 10.sp),
                            modifier = GlanceModifier.padding(top = 2.dp)
                        )
                    }
                    val canUndo = prefs.getInt("last_added_ml", 0) > 0
                    if (canUndo) {
                        Box(
                            modifier = GlanceModifier
                                .clickable(actionRunCallback<UndoBottleWaterAction>())
                                .cornerRadius(8.dp)
                                .background(c.card)
                                .padding(horizontal = 6.dp, vertical = 4.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text("↺", style = TextStyle(color = c.primary, fontWeight = FontWeight.Bold, fontSize = 12.sp))
                        }
                        Spacer(modifier = GlanceModifier.width(6.dp))
                    }
                    Text(
                        text = "\uD83D\uDD25 $streak",
                        maxLines = 1,
                        style = TextStyle(color = c.streak, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                    )
                }

                Spacer(modifier = GlanceModifier.height(8.dp))

                // The Bottle
                val bottleHeight = 84f
                Box(
                    modifier = GlanceModifier
                        .width(60.dp)
                        .height(bottleHeight.dp)
                        .cornerRadius(12.dp)
                        .background(c.card),
                    contentAlignment = Alignment.BottomCenter
                ) {
                    Box(
                        modifier = GlanceModifier
                            .fillMaxWidth()
                            .height((bottleHeight * progress).dp)
                            .cornerRadius(8.dp)
                            .background(if (isCompleted) completedColor else c.primary)
                    ) {}
                }

                Spacer(modifier = GlanceModifier.defaultWeight())

                // 2x2 Quick Add Buttons Grid
                Column(modifier = GlanceModifier.fillMaxWidth()) {
                    Row(modifier = GlanceModifier.fillMaxWidth()) {
                        listOf(100, 250).forEachIndexed { i, amt ->
                            if (i > 0) Spacer(modifier = GlanceModifier.width(6.dp))
                            Box(
                                modifier = GlanceModifier
                                    .defaultWeight()
                                    .clickable(actionRunCallback<AddBottleWaterAction>(actionParametersOf(amountKey to amt)))
                                    .cornerRadius(10.dp)
                                    .background(c.card)
                                    .padding(vertical = 8.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = "+$amt",
                                    maxLines = 1,
                                    style = TextStyle(color = c.primary, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                                )
                            }
                        }
                    }
                    Spacer(modifier = GlanceModifier.height(6.dp))
                    Row(modifier = GlanceModifier.fillMaxWidth()) {
                        listOf(300, 500).forEachIndexed { i, amt ->
                            if (i > 0) Spacer(modifier = GlanceModifier.width(6.dp))
                            Box(
                                modifier = GlanceModifier
                                    .defaultWeight()
                                    .clickable(actionRunCallback<AddBottleWaterAction>(actionParametersOf(amountKey to amt)))
                                    .cornerRadius(10.dp)
                                    .background(c.card)
                                    .padding(vertical = 8.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = "+$amt",
                                    maxLines = 1,
                                    style = TextStyle(color = c.primary, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}
