package com.example.focus_guard

import android.content.Context
import android.content.Intent
import android.os.PowerManager
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.focusguard/blocker"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            val prefs = getSharedPreferences("FocusGuardPrefs", Context.MODE_PRIVATE)
            when (call.method) {
                "isAccessibilityEnabled" -> result.success(isAccessibilityEnabled())
                "openAccessibilitySettings" -> {
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    result.success(null)
                }
                "isBatteryOptimizationIgnored" -> {
                    val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                    result.success(pm.isIgnoringBatteryOptimizations(packageName))
                }
                "requestBatteryOptimization" -> {
                    try {
                        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                            data = android.net.Uri.parse("package:$packageName")
                        }
                        startActivity(intent)
                    } catch (e: Exception) {
                        startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                    }
                    result.success(null)
                }
                "openAutostartSettings" -> {
                    try {
                        val intent = Intent().setComponent(android.content.ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity"))
                        startActivity(intent)
                    } catch (e: Exception) {
                        startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply { data = android.net.Uri.parse("package:$packageName") })
                    }
                    result.success(null)
                }
                "getSession" -> {
                    val map = hashMapOf<String, Any>(
                        "packages" to (prefs.getStringSet("blockedPackages", emptySet())?.toList() ?: emptyList<String>()),
                        "startAt" to prefs.getLong("startAt", 0),
                        "endAt" to prefs.getLong("endAt", 0),
                        "serviceConnected" to BlockerAccessibilityService.isConnected,
                        "lastPackage" to BlockerAccessibilityService.lastPackage
                    )
                    result.success(map)
                }
                // একটাই জায়গা - packages + time ২টাই একসাথে Save হবে
                "setBlockedApps", "setBlockedPackages", "setSession", "setSessionWithPackages" -> {
                    val list = call.argument<List<String>>("packages")
                    val s = (call.argument<Number>("startAt")?.toLong() ?: prefs.getLong("startAt", 0))
                    val e = (call.argument<Number>("endAt")?.toLong() ?: prefs.getLong("endAt", 0))
                    val editor = prefs.edit()
                    // packages পাঠাইলে ওইটা রাখবি, না পাঠাইলে আগেরটা রাখবি
                    if (list != null) {
                        editor.putStringSet("blockedPackages", list.toSet())
                    }
                    editor.putLong("startAt", s)
                    editor.putLong("endAt", e)
                    editor.commit()
                    result.success(true)
                }
                "clearSession" -> {
                    prefs.edit().putLong("startAt", 0).putLong("endAt", 0).putStringSet("blockedPackages", emptySet()).commit()
                    result.success(null)
                }
                "setBlockedFeatures" -> result.success(true)
                else -> result.notImplemented()
            }
        }
    }

    private fun isAccessibilityEnabled(): Boolean {
        val service = "$packageName/${BlockerAccessibilityService::class.java.canonicalName}"
        val enabledServices = Settings.Secure.getString(contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES)
        val accessibilityEnabled = Settings.Secure.getInt(contentResolver, Settings.Secure.ACCESSIBILITY_ENABLED, 0) == 1
        if (!accessibilityEnabled) return false
        val splitter = TextUtils.SimpleStringSplitter(':')
        splitter.setString(enabledServices)
        while (splitter.hasNext()) {
            if (splitter.next().equals(service, ignoreCase = true)) return true
        }
        return false
    }
}