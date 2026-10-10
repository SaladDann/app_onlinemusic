//android/app/src/main/kotlin/com/example/offline_music/media/playback/MusicNotificationProvider.kt
package com.example.offline_music.media.playback

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.RectF
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.media3.common.util.UnstableApi
import androidx.media3.session.CommandButton
import androidx.media3.session.MediaNotification
import androidx.media3.session.MediaSession
import com.example.offline_music.MainActivity
import com.example.offline_music.R
import com.google.common.collect.ImmutableList
import java.io.File
import java.io.FileInputStream
import java.io.InputStream

@UnstableApi
class MusicNotificationProvider(private val context: Context) : MediaNotification.Provider {

    private val notificationManager: NotificationManager =
        context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    fun createChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        if (notificationManager.getNotificationChannel(
                MusicPlaybackConstants.NOTIFICATION_CHANNEL_ID
            ) != null
        ) return

        val channel = NotificationChannel(
            MusicPlaybackConstants.NOTIFICATION_CHANNEL_ID,
            context.getString(R.string.notification_channel_name),
            NotificationManager.IMPORTANCE_DEFAULT
        ).apply {
            description = context.getString(R.string.notification_channel_description)
            setShowBadge(false)
            enableLights(false)
            enableVibration(false)
            setSound(null, null)
        }
        notificationManager.createNotificationChannel(channel)
    }

    override fun createNotification(
        mediaSession: MediaSession,
        mediaButtonPreferences: ImmutableList<CommandButton>,
        actionFactory: MediaNotification.ActionFactory,
        onNotificationChangedCallback: MediaNotification.Provider.Callback,
    ): MediaNotification {
        val player = mediaSession.player
        val metadata = player.mediaMetadata
        val songId = player.currentMediaItem?.mediaId
        val title = metadata.title?.toString()
            ?: context.getString(R.string.notification_unknown_title)
        val artist = metadata.artist?.toString()
            ?: context.getString(R.string.notification_unknown_artist)
        val artworkUri = metadata.artworkUri?.toString()
        val isPlaying = player.isPlaying
        val isFavorite = MusicPlaybackStateHolder.isFavorite

        Log.d("MusicNotification", "createNotification: artworkUri=$artworkUri")

        val remoteViews = RemoteViews(context.packageName, R.layout.notification_media).apply {
            setImageViewBitmap(R.id.notification_artwork, loadArtwork(artworkUri))
            setTextViewText(R.id.notification_title, title)
            setTextViewText(R.id.notification_artist, artist)
            setImageViewResource(
                R.id.notification_play_pause,
                if (isPlaying) R.drawable.ic_pause else R.drawable.ic_play
            )
            setImageViewResource(
                R.id.notification_favorite,
                if (isFavorite) R.drawable.ic_heart_filled else R.drawable.ic_heart_outline
            )
            setInt(
                R.id.notification_favorite,
                "setColorFilter",
                if (isFavorite) context.getColor(R.color.notification_icon_tint_active)
                else context.getColor(R.color.notification_icon_tint)
            )

            setOnClickPendingIntent(R.id.notification_close, actionIntent(MusicPlaybackConstants.ACTION_CLOSE))
            setOnClickPendingIntent(R.id.notification_favorite, actionIntent(MusicPlaybackConstants.ACTION_FAVORITE))
            setOnClickPendingIntent(R.id.notification_previous, actionIntent(MusicPlaybackConstants.ACTION_PREVIOUS))
            setOnClickPendingIntent(R.id.notification_play_pause, actionIntent(MusicPlaybackConstants.ACTION_TOGGLE))
            setOnClickPendingIntent(R.id.notification_next, actionIntent(MusicPlaybackConstants.ACTION_NEXT))
        }

        val notification = NotificationCompat.Builder(
            context,
            MusicPlaybackConstants.NOTIFICATION_CHANNEL_ID
        )
            .setSmallIcon(R.drawable.ic_notification)
            .setCustomContentView(remoteViews)
            .setCustomBigContentView(remoteViews)
            .setContentIntent(buildContentIntent(songId))
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setCategory(NotificationCompat.CATEGORY_TRANSPORT)
            .build()

        return MediaNotification(MusicPlaybackConstants.NOTIFICATION_ID, notification)
    }

    override fun handleCustomCommand(
        session: MediaSession,
        action: String,
        extras: Bundle,
    ): Boolean = false

    private fun buildContentIntent(songId: String?): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            if (songId != null) putExtra(MusicPlaybackConstants.KEY_ID, songId)
        }
        return PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun actionIntent(action: String): PendingIntent {
        val intent = Intent(context, MusicPlaybackActionReceiver::class.java).apply {
            this.action = action
        }
        return PendingIntent.getBroadcast(
            context,
            action.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun loadArtwork(uri: String?): Bitmap {
        val bitmap = if (uri.isNullOrBlank()) defaultArtwork() else loadArtworkFromUri(uri)
        return roundCorners(bitmap, 10f)
    }

    private fun loadArtworkFromUri(uri: String): Bitmap {
        Log.d("MusicNotification", "loadArtworkFromUri: $uri")
        return try {
            val input: InputStream? = when {
                uri.startsWith("content://") -> {
                    context.contentResolver.openInputStream(Uri.parse(uri))
                }
                uri.startsWith("file://") -> {
                    val path = Uri.parse(uri).path
                    if (path != null) FileInputStream(File(path)) else null
                }
                uri.startsWith("/") -> {
                    FileInputStream(File(uri))
                }
                else -> {
                    context.contentResolver.openInputStream(Uri.parse(uri))
                }
            }

            val bitmap = input?.use { BitmapFactory.decodeStream(it) }
            Log.d("MusicNotification", "loadArtworkFromUri result: ${bitmap != null}")
            bitmap ?: defaultArtwork()
        } catch (e: Exception) {
            Log.e("MusicNotification", "loadArtworkFromUri error: $e")
            defaultArtwork()
        }
    }

    private fun defaultArtwork(): Bitmap {
        val drawable = context.getDrawable(R.drawable.ic_notification)!!
        val size = 256
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val bg = context.getColor(R.color.notification_icon_tint)
        canvas.drawColor(adjustAlpha(bg, 0.15f))
        drawable.setBounds(size / 4, size / 4, size * 3 / 4, size * 3 / 4)
        drawable.setTint(context.getColor(R.color.notification_icon_tint))
        drawable.draw(canvas)
        return bitmap
    }

    private fun roundCorners(bitmap: Bitmap, radiusDp: Float): Bitmap {
        val output = Bitmap.createBitmap(bitmap.width, bitmap.height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(output)
        val paint = android.graphics.Paint().apply {
            isAntiAlias = true
            color = android.graphics.Color.WHITE
        }
        val rect = RectF(0f, 0f, bitmap.width.toFloat(), bitmap.height.toFloat())
        val radiusPx = radiusDp * context.resources.displayMetrics.density
        canvas.drawRoundRect(rect, radiusPx, radiusPx, paint)
        paint.xfermode = android.graphics.PorterDuffXfermode(android.graphics.PorterDuff.Mode.SRC_IN)
        canvas.drawBitmap(bitmap, 0f, 0f, paint)
        return output
    }

    private fun adjustAlpha(color: Int, factor: Float): Int {
        val alpha = (android.graphics.Color.alpha(color) * factor).toInt()
        val red = android.graphics.Color.red(color)
        val green = android.graphics.Color.green(color)
        val blue = android.graphics.Color.blue(color)
        return android.graphics.Color.argb(alpha, red, green, blue)
    }
}
