//android/app/src/main/kotlin/com/example/offline_music/media/AudioDecoderChecker.kt
package com.example.offline_music.media

import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import java.io.File

internal object AudioDecoderChecker {

    data class Result(
        val available: Boolean,
        val mimeType: String?,
        val reason: String
    )

    fun check(inputPath: String): Result {
        val inputFile = File(inputPath)
        if (!inputFile.exists()) {
            return Result(false, null, "El archivo no existe.")
        }

        var extractor: MediaExtractor? = null
        var decoder: MediaCodec? = null

        try {
            extractor = MediaExtractor().apply {
                setDataSource(inputFile.absolutePath)
            }

            val (audioFormat, mimeType) = findFirstAudioTrack(extractor)
                ?: return Result(
                    available = false,
                    mimeType = null,
                    reason = "No se encontró una pista de audio válida."
                )

            decoder = try {
                MediaCodec.createDecoderByType(mimeType)
            } catch (e: Exception) {
                return Result(
                    available = false,
                    mimeType = mimeType,
                    reason = "MediaCodec no pudo crear un decoder para $mimeType: " +
                        (e.localizedMessage ?: e.javaClass.simpleName)
                )
            }

            return try {
                decoder.configure(audioFormat, null, null, 0)
                Result(
                    available = true,
                    mimeType = mimeType,
                    reason = "Decoder creado y configurado correctamente."
                )
            } catch (e: Exception) {
                Result(
                    available = false,
                    mimeType = mimeType,
                    reason = "El decoder existe pero no pudo configurarse para " +
                        "$mimeType: " + (e.localizedMessage ?: e.javaClass.simpleName)
                )
            }
        } catch (e: Exception) {
            return Result(
                available = false,
                mimeType = null,
                reason = e.localizedMessage ?: e.javaClass.simpleName
            )
        } finally {
            runCatching { decoder?.release() }
            runCatching { extractor?.release() }
        }
    }

    private fun findFirstAudioTrack(
        extractor: MediaExtractor
    ): Pair<MediaFormat, String>? {
        for (trackIndex in 0 until extractor.trackCount) {
            val format = extractor.getTrackFormat(trackIndex)
            val mime = format.getString(MediaFormat.KEY_MIME) ?: continue
            if (mime.startsWith(MediaConstants.AUDIO_MIME_PREFIX)) {
                return format to mime
            }
        }
        return null
    }
}
