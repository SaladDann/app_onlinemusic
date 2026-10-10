//android/app/src/main/kotlin/com/example/offline_music/media/AudioMimeDetector.kt
package com.example.offline_music.media

import android.media.MediaExtractor
import android.media.MediaFormat
import java.io.File

internal object AudioMimeDetector {

    fun detect(inputPath: String): String? {
        val inputFile = File(inputPath)
        require(inputFile.exists()) { "El archivo no existe: $inputPath" }

        var extractor: MediaExtractor? = null
        try {
            extractor = MediaExtractor().apply {
                setDataSource(inputFile.absolutePath)
            }

            for (trackIndex in 0 until extractor.trackCount) {
                val format = extractor.getTrackFormat(trackIndex)
                val mime = format.getString(MediaFormat.KEY_MIME)
                if (mime != null && mime.startsWith(MediaConstants.AUDIO_MIME_PREFIX)) {
                    return mime
                }
            }
            return null
        } finally {
            runCatching { extractor?.release() }
        }
    }
}
