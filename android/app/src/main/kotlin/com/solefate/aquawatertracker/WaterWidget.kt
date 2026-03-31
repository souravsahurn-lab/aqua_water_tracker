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
import androidx.glance.appwidget.LinearProgressIndicator
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

// ── Theme colors ────────────────────────────────────────────────
data class WidgetColors(
    val bg: ColorProvider,
    val card: ColorProvider,
    val primary: ColorProvider,
    val textMain: ColorProvider,
    val textSub: ColorProvider,
    val streak: ColorProvider
)

val dynamicColors = WidgetColors(
    bg       = ColorProvider(R.color.widget_bg),
    card     = ColorProvider(R.color.widget_card),
    primary  = ColorProvider(R.color.widget_primary),
    textMain = ColorProvider(R.color.widget_text_main),
    textSub  = ColorProvider(R.color.widget_text_sub),
    streak   = ColorProvider(R.color.widget_streak)
)

// ── Action callback ─────────────────────────────────────────────
class AddWaterAction : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        val amount = parameters[amountKey] ?: 0
        if (amount <= 0) return

        // 1. Immediately update widget prefs for instant visual feedback
        val prefs = HomeWidgetPlugin.getData(context)
        val currentIntake = prefs.getInt("intake", 0)
        prefs.edit()
            .putInt("intake", currentIntake + amount)
            .putInt("last_added_ml", amount)
            .apply()

        // 2. Refresh widget UI immediately
        WaterWidget().update(context, glanceId)

        // 3. Fire Dart background callback to persist in Flutter storage
        try {
            HomeWidgetBackgroundIntent.getBroadcast(
                context,
                Uri.parse("waterWidget://add/$amount")
            ).send()
        } catch (_: Exception) {}
    }
}

class UndoWaterAction : ActionCallback {
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

            WaterWidget().update(context, glanceId)

            try {
                HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("waterWidget://undo")
                ).send()
            } catch (_: Exception) {}
        }
    }
}

// ── Widget ──────────────────────────────────────────────────────
class WaterWidget : GlanceAppWidget() {
    override val stateDefinition: GlanceStateDefinition<*> = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val ctx = LocalContext.current
            val c = dynamicColors
            
            // Connect Compose to HomeWidget SharedPreferences
            val state = currentState<HomeWidgetGlanceState>()
            val prefs = state.preferences

            val intake  = prefs.getInt("intake", 0)
            val goal    = prefs.getInt("goal", 2450).coerceAtLeast(1)
            val streak  = prefs.getInt("streak", 0)
            val nextRem = prefs.getString("next_reminder", "--:--") ?: "--:--"

            val progress = (intake.toFloat() / goal.toFloat()).coerceIn(0f, 1f)
            val pctStr   = String.format("%.0f", progress * 100)
            val remaining = (goal - intake).coerceAtLeast(0)

            // ── Root ──
            Row(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .cornerRadius(16.dp)
                    .background(c.bg)
                    .padding(horizontal = 14.dp, vertical = 6.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Left Side: Stats Information
                Column(
                    modifier = GlanceModifier.defaultWeight()
                ) {
                    Row(verticalAlignment = Alignment.Bottom) {
                        Text(
                            text = "$intake",
                            maxLines = 1,
                            style = TextStyle(
                                color = c.textMain,
                                fontWeight = FontWeight.Bold,
                                fontSize = 20.sp
                            )
                        )
                        Text(
                            text = " / $goal ml",
                            maxLines = 1,
                            style = TextStyle(
                                color = c.textSub,
                                fontWeight = FontWeight.Medium,
                                fontSize = 11.sp
                            ),
                            modifier = GlanceModifier.padding(bottom = 2.dp, start = 4.dp)
                        )
                        Text(
                            text = "   \uD83D\uDD25 $streak",
                            maxLines = 1,
                            style = TextStyle(
                                color = c.streak,
                                fontWeight = FontWeight.Bold,
                                fontSize = 11.sp
                            ),
                            modifier = GlanceModifier.padding(bottom = 2.dp)
                        )
                        val canUndo = prefs.getInt("last_added_ml", 0) > 0
                        if (canUndo) {
                            Spacer(modifier = GlanceModifier.width(8.dp))
                            Box(
                                modifier = GlanceModifier
                                    .clickable(actionRunCallback<UndoWaterAction>())
                                    .cornerRadius(6.dp)
                                    .background(c.card)
                                    .padding(horizontal = 6.dp, vertical = 2.dp)
                            ) {
                                Text("↺", style = TextStyle(color = c.primary, fontWeight = FontWeight.Bold, fontSize = 11.sp))
                            }
                        }
                    }

                    Spacer(modifier = GlanceModifier.height(4.dp))

                    LinearProgressIndicator(
                        progress = progress,
                        modifier = GlanceModifier
                            .fillMaxWidth()
                            .height(6.dp)
                            .cornerRadius(3.dp),
                        color = c.primary,
                        backgroundColor = c.card
                    )

                    Spacer(modifier = GlanceModifier.height(4.dp))

                    Text(
                        text = "🔔 $nextRem  ·  $pctStr%  ·  ${remaining}ml left",
                        maxLines = 1,
                        style = TextStyle(
                            color = c.primary,
                            fontWeight = FontWeight.Medium,
                            fontSize = 11.sp
                        )
                    )
                }

                Spacer(modifier = GlanceModifier.width(16.dp))

                // Right Side: 2x2 Grid of Quick Add Buttons
                Column(horizontalAlignment = Alignment.End) {
                    Row {
                        QuickAddBtn(100, c)
                        Spacer(modifier = GlanceModifier.width(4.dp))
                        QuickAddBtn(250, c)
                    }
                    Spacer(modifier = GlanceModifier.height(4.dp))
                    Row {
                        QuickAddBtn(300, c)
                        Spacer(modifier = GlanceModifier.width(4.dp))
                        QuickAddBtn(500, c)
                    }
                }
            }
        }
    }
}

// ── Reusable button ─────────────────────────────────────────────
@Composable
private fun QuickAddBtn(amount: Int, c: WidgetColors) {
    Box(
        modifier = GlanceModifier
            .clickable(
                actionRunCallback<AddWaterAction>(
                    actionParametersOf(amountKey to amount)
                )
            )
            .cornerRadius(8.dp)
            .background(c.card)
            .padding(horizontal = 8.dp, vertical = 6.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = "+$amount",
            maxLines = 1,
            style = TextStyle(
                color = c.primary,
                fontWeight = FontWeight.Bold,
                fontSize = 12.sp
            )
        )
    }
}
