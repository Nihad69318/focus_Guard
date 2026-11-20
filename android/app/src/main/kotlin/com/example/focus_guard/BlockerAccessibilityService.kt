package com.example.focus_guard

import android.accessibilityservice.AccessibilityService
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.view.accessibility.AccessibilityEvent
import android.widget.Toast
import androidx.core.app.NotificationCompat

class BlockerAccessibilityService : AccessibilityService() {
    companion object {
        var isConnected = false
        var lastPackage = ""
    }

    private var lastBlockTime = 0L

    override fun onServiceConnected() {
        super.onServiceConnected()
        isConnected = true
        startAsForeground()
    }

    override fun onUnbind(intent: Intent?): Boolean {
        isConnected = false
        return super.onUnbind(intent)
    }

    private fun startAsForeground() {
        val channelId = "focus_guard_blocker"
        val nm = getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val ch = NotificationChannel(channelId, "Focus Guard Protection", NotificationManager.IMPORTANCE_LOW)
            nm?.createNotificationChannel(ch)
        }
        val notif = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setContentTitle("Focus Guard Active")
            .setContentText("Your apps are protected")
            .setOngoing(true)
            .build()
        try {
            startForeground(1, notif)
        } catch (e: Exception) {
            // Android 14+ এ মাঝে মাঝে Foreground permission না থাকলে crash করে, তাই try-catch
        }
    }

    private fun getBlockedSet(): Set<String> {
        // FIX 1: Flutter এর SharedPreferences ফাইল থেকে পড়তেছি
        // Flutter shared_preferences_android "FlutterSharedPreferences" ফাইলে রাখে
        // আর key এর আগে "flutter." বসায়
        val flutterPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        // 1. নতুন way - flutter. prefix সহ
        var set = flutterPrefs.getStringSet("flutter.blockedPackages", null)
        if (set != null) return set

        // 2. পুরাতন way - prefix ছাড়া
        set = flutterPrefs.getStringSet("blockedPackages", null)
        if (set != null) return set

        // 3. Fallback - যদি তুমি MethodChannel দিয়ে FocusGuardPrefs এ লিখো
        val p1 = getSharedPreferences("FocusGuardPrefs", Context.MODE_PRIVATE)
        return p1.getStringSet("blockedPackages", emptySet()) ?: emptySet()
    }

    private fun getSession(): Pair<Long, Long> {
        val flutterPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        // Flutter থেকে Long পাঠালে এইভাবে আসে
        var start = flutterPrefs.getLong("flutter.startAt", 0L)
        var end = flutterPrefs.getLong("flutter.endAt", 0L)
        if (start != 0L || end != 0L) return Pair(start, end)

        start = flutterPrefs.getLong("startAt", 0L)
        end = flutterPrefs.getLong("endAt", 0L)
        if (start != 0L || end != 0L) return Pair(start, end)

        val p1 = getSharedPreferences("FocusGuardPrefs", Context.MODE_PRIVATE)
        return Pair(p1.getLong("startAt", 0), p1.getLong("endAt", 0))
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return

        val pkg = event.packageName?.toString() ?: return
        if (pkg == packageName) return
        if (pkg == "com.miui.home" || pkg == "com.android.systemui") return
        lastPackage = pkg

        val (startAt, endAt) = getSession()
        val now = System.currentTimeMillis()

        // Session না থাকলে (0,0) মানে সবসময় Block করবে - এটা ইচ্ছা করে রাখলাম
        // তুমি যদি চাও সবসময় Block হবে, তাহলে Flutter থেকে startAt=0, endAt=0 পাঠাবা না
        // Flutter থেকে startAt/endAt সেট না করলে এখন Block হবে না, নিচের লাইনটা দেখো
        if (startAt != 0L && endAt != 0L) {
            if (now < startAt || now >= endAt) return
        }

        val blocked = getBlockedSet()
        if (blocked.isEmpty()) return

        if (blocked.contains(pkg)) {
            // 2 সেকেন্ডের CoolDown - বার বার Toast আসবে না
            if (now - lastBlockTime < 2000) return
            lastBlockTime = now

            Toast.makeText(this, "Blocked: $pkg", Toast.LENGTH_SHORT).show()
            performGlobalAction(GLOBAL_ACTION_HOME)
        }
    }

    override fun onInterrupt() {}
}