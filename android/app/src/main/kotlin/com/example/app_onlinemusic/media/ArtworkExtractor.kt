//android/app/src/main/kotlin/com/example/offline_music/media/ArtworkExtractor.kt
package com.example.offline_music.media

import android.media.MediaMetadataRetriever
import java.io.File

internal class ArtworkExtractor(private val cacheDir: File) {

    private val artworkDir: File by lazy {
        File(cacheDir, "offline_music_artwork").apply {
            if (!exists()) mkdirs()
        }
    }

    fun artworkCacheDirPath(): String = artworkDir.absolutePath

    fun alacCacheDirPath(): String =
        File(cacheDir, "offline_music_alac").absolutePath

    fun appCacheDirPath(): String = cacheDir.absolutePath

    fun extract(inputPath: String): String? {
        val inputFile = File(inputPath)
        if (!inputFile.exists()) return null

        val cached = cachedFileFor(inputFile)
        if (cached.exists() && cached.length() > 0) {
            return cached.absolutePath
        }

        val retriever = MediaMetadataRetriever()
        try {
            retriever.setDataSource(inputFile.absolutePath)
            val picture = retriever.embeddedPicture ?: return null
            if (picture.isEmpty()) return null
            cached.writeBytes(picture)
            return cached.absolutePath
        } catch (_: Exception) {
            return null
        } finally {
            try {
                retriever.release()
            } catch (_: Exception) {
            }
        }
    }

    private fun cachedFileFor(inputFile: File): File {
        val key = "${inputFile.absolutePath}_${inputFile.lastModified()}"
        val hash = key.hashCode().toUInt().toString(16)
        return File(artworkDir, "art_$hash.img")
    }
}
