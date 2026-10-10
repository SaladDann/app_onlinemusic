//android/app/src/main/kotlin/com/example/offline_music/MainActivity.kt
package com.example.offline_music

import com.example.offline_music.media.MediaChannelHandler
import com.example.offline_music.media.MediaConstants
import com.example.offline_music.media.playback.MusicPlaybackBridge
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var mediaHandler: MediaChannelHandler? = null
    private var playbackBridge: MusicPlaybackBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val handler = MediaChannelHandler(
            context = applicationContext,
            runOnUiThread = { runnable -> runOnUiThread(runnable) }
        )
        mediaHandler = handler

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            MediaConstants.CHANNEL
        ).setMethodCallHandler(handler)

        val bridge = MusicPlaybackBridge(
            context = applicationContext,
            messenger = flutterEngine.dartExecutor.binaryMessenger,
        )
        bridge.start()
        playbackBridge = bridge
    }

    override fun onDestroy() {
        playbackBridge?.stop()
        playbackBridge = null
        mediaHandler?.shutdown()
        mediaHandler = null
        super.onDestroy()
    }
}
