package com.example.focus_guard

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null || intent == null) return

        if (intent.action == Intent.ACTION_BOOT_COMPLETED || intent.action == Intent.ACTION_MY_PACKAGE_REPLACED) {
            Log.d("BootReceiver", "Phone restarted, Focus Guard will resume")
            // NOTE: Accessibility Service কে এখান থেকে চালু করা যাবে না।
            // ইউজারকে Settings থেকে একবার ON করতে হয়, তারপর ফোন Restart দিলেও Android নিজে থেকেই ওইটা আবার চালু করে দেয়।
            // তাই এখানে আমরা কিছুই চালু করবো না, শুধু Log রাখলাম।
            // তুমি চাইলে এখান থেকে Foreground Service চালু করতে পারো, কিন্তু Accessibility এর জন্য দরকার নাই।
        }
    }
}