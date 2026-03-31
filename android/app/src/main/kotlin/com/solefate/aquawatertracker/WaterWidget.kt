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

        val prefs = HomeWidgetPlugin.getData(context)
        val currentIntake = prefs.getInt("intake", 0)
        prefs.edit()
            .putInt("intake", currentIntake + amount)
            .putInt("last_added_ml", amount)
            .apply()

        WaterWidget().update(context, glanceId)

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
            val completedColor = ColorProvider(Color(0xFF22C55E))
            
            val state = currentState<HomeWidgetGlanceState>()
            val prefs = state.preferences

            val isPremium = prefs.getBoolean("is_premium", false)

            if (!isPremium) {
                // Locked overlay
                Box(
                    modifier = GlanceModifier
                        .fillMaxSize()
                        .cornerRadius(16.dp)
                        .background(c.bg)
                        .padding(horizontal = 14.dp, vertical = 8.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            text = "🔒",
                            style = TextStyle(fontSize = 18.sp)
                        )
                        Spacer(modifier = GlanceModifier.width(8.dp))
                        Column {
                            Text(
                                text = "Aqua Pro Required",
                                style = TextStyle(
                                    color = c.textMain,
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 13.sp
                                )
                            )
                            Text(
                                text = "Upgrade to unlock widgets",
                                style = TextStyle(
                                    color = c.textSub,
                                    fontSize = 10.sp
                                )
                            )
                        }
                    }
                }
                return@provideContent
            }

            val intake  = prefs.getInt("intake", 0)
            val goal    = prefs.getInt("goal", 2450).coerceAtLeast(1)
            val streak  = prefs.getInt("streak", 0)
            val nextRem = prefs.getString("next_reminder", "--:--") ?: "--:--"

            val progress = (intake.toFloat() / goal.toFloat()).coerceIn(0f, 1f)
            val pctStr   = String.format("%.0f", progress * 100)
            val remaining = (goal - intake).coerceAtLeast(0)
            val isCompleted = intake >= goal

            // ── Root ──
            Row(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .cornerRadius(16.dp)
                    .background(c.bg)
                    .padding(horizontal = 14.dp, vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // ── Left: Stats ──
                Column(
                    modifier = GlanceModifier.defaultWeight()
                ) {
                    Row(verticalAlignment = Alignment.Bottom) {
                        Text(
                            text = "$intake",
                            maxLines = 1,
                            style = TextStyle(
                                color = if (isCompleted) completedColor else c.textMain,
                                fontWeight = FontWeight.Bold,
                                fontSize = 22.sp
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
                            modifier = GlanceModifier.padding(bottom = 3.dp, start = 3.dp)
                        )
                        Text(
                            text = "  \uD83D\uDD25 $streak",
                            maxLines = 1,
                            style = TextStyle(
                                color = c.streak,
                                fontWeight = FontWeight.Bold,
                                fontSize = 11.sp
                            ),
                            modifier = GlanceModifier.padding(bottom = 3.dp)
                        )
                    }

                    Spacer(modifier = GlanceModifier.height(5.dp))

                    LinearProgressIndicator(
                        progress = progress,
                        modifier = GlanceModifier
                            .fillMaxWidth()
                            .height(8.dp)
                            .cornerRadius(4.dp),
                        color = if (isCompleted) completedColor else c.primary,
                        backgroundColor = c.card
                    )

                    Spacer(modifier = GlanceModifier.height(5.dp))

                    Text(
                        text = "$pctStr%  ·  ${remaining}ml left  ·  🔔 $nextRem",
                        maxLines = 1,
                        style = TextStyle(
                            color = c.textSub,
                            fontWeight = FontWeight.Medium,
                            fontSize = 10.sp
                        )
                    )
                }

                Spacer(modifier = GlanceModifier.width(14.dp))

                // ── Right: 2×2 Quick-add ──
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
            .padding(horizontal = 10.dp, vertical = 7.dp),
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
