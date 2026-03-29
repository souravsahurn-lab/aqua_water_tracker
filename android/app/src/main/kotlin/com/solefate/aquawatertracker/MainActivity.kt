package com.solefate.aquawatertracker

import android.os.Bundle
import android.graphics.Color
import io.flutter.embedding.android.FlutterActivity
import androidx.core.view.WindowCompat

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Ensure the content draws behind system bars
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
        // Force transparency at the window level
        window.statusBarColor = Color.TRANSPARENT
        window.navigationBarColor = Color.TRANSPARENT
        
        // For Android 10+ (API 29+), ensure contrast is disabled
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
            window.isNavigationBarContrastEnforced = false
            window.isStatusBarContrastEnforced = false
        }
    }
}
