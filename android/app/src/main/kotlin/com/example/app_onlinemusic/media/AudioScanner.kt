//android/app/src/main/kotlin/com/example/offline_music/media/AudioScanner.kt
package com.example.offline_music.media

import android.content.ContentResolver
import android.content.ContentUris
import android.database.Cursor
import android.net.Uri
import android.provider.MediaStore

internal class AudioScanner(private val contentResolver: ContentResolver) {

    fun scan(): List<Map<String, Any>> {
        val songs = mutableListOf<Map<String, Any>>()
        val audioUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI

        contentResolver.query(
            audioUri,
            PROJECTION,
            SELECTION,
            null,
            "${MediaStore.Audio.Media.TITLE} COLLATE NOCASE ASC"
        )?.use { cursor ->
            val columns = ColumnIndices.from(cursor)
            while (cursor.moveToNext()) {
                songs.add(buildSong(cursor, audioUri, columns))
            }
        }

        return songs
    }

    private fun buildSong(
        cursor: Cursor,
        audioUri: Uri,
        columns: ColumnIndices
    ): Map<String, Any> {
        val songId = cursor.getLong(columns.id)
        val contentUri = ContentUris.withAppendedId(audioUri, songId).toString()

        return mapOf(
            "id" to songId.toString(),
            "title" to cursor.getStringOrFallback(columns.title, MediaConstants.UNKNOWN_LABEL),
            "artist" to cursor.getStringOrFallback(columns.artist, MediaConstants.UNKNOWN_LABEL),
            "album" to cursor.getStringOrFallback(columns.album, MediaConstants.UNKNOWN_LABEL),
            "uri" to contentUri,
            "data" to cursor.getStringOrFallback(columns.data, ""),
            "duration" to cursor.getLong(columns.duration),
            "fileSize" to cursor.getLong(columns.size),
            "dateModified" to cursor.getLong(columns.dateModified),
            "mimeType" to cursor.getStringOrFallback(columns.mime, MediaConstants.FALLBACK_MIME),
            "fileName" to cursor.getStringOrFallback(columns.name, "")
        )
    }

    private fun Cursor.getStringOrFallback(columnIndex: Int, fallback: String): String =
        getString(columnIndex)?.takeIf { it.isNotBlank() } ?: fallback

    private data class ColumnIndices(
        val id: Int,
        val title: Int,
        val artist: Int,
        val album: Int,
        val data: Int,
        val duration: Int,
        val size: Int,
        val mime: Int,
        val name: Int,
        val dateModified: Int
    ) {
        companion object {
            fun from(cursor: Cursor): ColumnIndices = ColumnIndices(
                id = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID),
                title = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE),
                artist = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST),
                album = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM),
                data = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA),
                duration = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION),
                size = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.SIZE),
                mime = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.MIME_TYPE),
                name = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DISPLAY_NAME),
                dateModified = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATE_MODIFIED)
            )
        }
    }

    private companion object {
        val PROJECTION = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.DATA,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.SIZE,
            MediaStore.Audio.Media.MIME_TYPE,
            MediaStore.Audio.Media.DISPLAY_NAME,
            MediaStore.Audio.Media.DATE_MODIFIED
        )

        const val SELECTION = "${MediaStore.Audio.Media.IS_MUSIC} != 0"
    }
}
