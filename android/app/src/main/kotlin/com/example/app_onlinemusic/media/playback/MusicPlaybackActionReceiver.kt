//android/app/src/main/kotlin/com/example/offline_music/media/playback/MusicPlaybackActionReceiver
package com.example.offline_music.media.playback

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class MusicPlaybackActionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return

        val serviceIntent = Intent(context, MusicPlaybackService::class.java).apply {
            this.action = action
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }
    }
}
