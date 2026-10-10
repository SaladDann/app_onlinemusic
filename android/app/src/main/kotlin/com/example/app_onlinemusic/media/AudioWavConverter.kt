//android/app/src/main/kotlin/com/example/offline_music/media/AudioWavConverter.kt
package com.example.offline_music.media

import android.media.AudioFormat
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

internal class AudioWavConverter(
    private val cacheDir: File
) {

    /**
     * Decodifica una pista de audio y genera un archivo WAV.
     *
     * Si outputPath no se proporciona, conserva la ubicación
     * predeterminada utilizada por las conversiones existentes.
     */
    fun convert(
        inputPath: String,
        outputPath: String? = null
    ): String {
        val inputFile = File(inputPath.trim()).canonicalFile

        require(inputFile.isFile) {
            "El archivo de entrada no existe o no es válido: $inputPath"
        }

        val destinationFile = resolveOutputFile(inputFile, outputPath)

        require(inputFile != destinationFile.canonicalFile) {
            "El archivo de salida no puede ser el mismo que el archivo de entrada."
        }

        val parentDirectory = destinationFile.parentFile
            ?: throw IOException("No se pudo determinar el directorio de salida.")

        if (!parentDirectory.exists() && !parentDirectory.mkdirs()) {
            throw IOException(
                "No se pudo crear el directorio de salida: ${parentDirectory.absolutePath}"
            )
        }

        if (!parentDirectory.isDirectory) {
            throw IOException(
                "La ruta de salida no es un directorio válido: ${parentDirectory.absolutePath}"
            )
        }

        var extractor: MediaExtractor? = null
        var codec: MediaCodec? = null
        var outputStream: FileOutputStream? = null
        var outputFile: File? = null

        try {
            extractor = MediaExtractor().apply {
                setDataSource(inputFile.absolutePath)
            }

            val audioTrack = findAudioTrack(extractor)
                ?: throw IllegalArgumentException(
                    "No se encontró una pista de audio válida."
                )

            val (trackIndex, inputFormat, mimeType) = audioTrack

            extractor.selectTrack(trackIndex)

            codec = createDecoder(mimeType).apply {
                configure(inputFormat, null, null, 0)
                start()
            }

            outputFile = destinationFile

            outputStream = FileOutputStream(outputFile).apply {
                write(ByteArray(MediaConstants.WAV_HEADER_SIZE))
            }

            val stats = pumpPcmData(
                codec = codec,
                extractor = extractor,
                outputStream = outputStream
            )

            if (stats.totalPcmSize <= 0L) {
                throw IOException("El decodificador no produjo datos PCM.")
            }

            outputStream.flush()
            outputStream.close()
            outputStream = null

            WavHeaderWriter.write(
                file = outputFile,
                totalAudioLen = stats.totalPcmSize,
                sampleRate = stats.sampleRate,
                channels = stats.channels,
                bitsPerSample = stats.bitsPerSample
            )

            return outputFile.absolutePath
        } catch (e: Exception) {
            runCatching { outputStream?.close() }
            runCatching { outputFile?.delete() }
            throw e
        } finally {
            runCatching { codec?.stop() }
            runCatching { codec?.release() }
            runCatching { extractor?.release() }
        }
    }

    private fun resolveOutputFile(
        inputFile: File,
        outputPath: String?
    ): File {
        val requestedPath = outputPath?.trim()

        return if (!requestedPath.isNullOrEmpty()) {
            File(requestedPath).absoluteFile
        } else {
            File(
                cacheDir,
                "${inputFile.nameWithoutExtension}_decoded.wav"
            ).absoluteFile
        }
    }

    private fun findAudioTrack(
        extractor: MediaExtractor
    ): Triple<Int, MediaFormat, String>? {
        for (trackIndex in 0 until extractor.trackCount) {
            val format = extractor.getTrackFormat(trackIndex)
            val mimeType = format.getString(MediaFormat.KEY_MIME) ?: continue

            if (mimeType.startsWith(MediaConstants.AUDIO_MIME_PREFIX)) {
                return Triple(trackIndex, format, mimeType)
            }
        }

        return null
    }

    private fun createDecoder(mimeType: String): MediaCodec {
        return try {
            MediaCodec.createDecoderByType(mimeType)
        } catch (e: Exception) {
            throw IllegalArgumentException(
                "El dispositivo no dispone de un decodificador compatible para $mimeType.",
                e
            )
        }
    }

    private fun pumpPcmData(
        codec: MediaCodec,
        extractor: MediaExtractor,
        outputStream: FileOutputStream
    ): DecodeStats {
        val bufferInfo = MediaCodec.BufferInfo()
        var inputFinished = false
        var outputFinished = false
        var idleIterations = 0
        var totalPcmSize = 0L

        val stats = DecodeStats(
            sampleRate = MediaConstants.DEFAULT_SAMPLE_RATE,
            channels = MediaConstants.DEFAULT_CHANNELS,
            bitsPerSample = MediaConstants.DEFAULT_BITS_PER_SAMPLE
        )

        while (!outputFinished) {
            if (!inputFinished) {
                inputFinished = feedInput(
                    codec = codec,
                    extractor = extractor
                )
            }

            when (
                val outputBufferIndex = codec.dequeueOutputBuffer(
                    bufferInfo,
                    MediaConstants.CODEC_TIMEOUT_US
                )
            ) {
                MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                    stats.updateFrom(codec.outputFormat)
                    idleIterations = 0
                }

                MediaCodec.INFO_TRY_AGAIN_LATER -> {
                    idleIterations++

                    if (idleIterations > MediaConstants.MAX_IDLE_ITERATIONS) {
                        throw IllegalStateException(
                            "MediaCodec no produjo salida después de múltiples intentos."
                        )
                    }
                }

                else -> {
                    idleIterations = 0

                    if (outputBufferIndex >= 0) {
                        totalPcmSize += drainOutput(
                            codec = codec,
                            outputBufferIndex = outputBufferIndex,
                            bufferInfo = bufferInfo,
                            outputStream = outputStream
                        )

                        if (
                            bufferInfo.flags and
                            MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0
                        ) {
                            outputFinished = true
                        }
                    }
                }
            }
        }

        stats.totalPcmSize = totalPcmSize
        return stats
    }

    private fun feedInput(
        codec: MediaCodec,
        extractor: MediaExtractor
    ): Boolean {
        val inputBufferIndex = codec.dequeueInputBuffer(
            MediaConstants.CODEC_TIMEOUT_US
        )

        if (inputBufferIndex < 0) {
            return false
        }

        val inputBuffer = codec.getInputBuffer(inputBufferIndex)

        if (inputBuffer == null) {
            codec.queueInputBuffer(
                inputBufferIndex,
                0,
                0,
                0L,
                0
            )
            return false
        }

        inputBuffer.clear()

        val sampleSize = extractor.readSampleData(inputBuffer, 0)

        return if (sampleSize < 0) {
            codec.queueInputBuffer(
                inputBufferIndex,
                0,
                0,
                0L,
                MediaCodec.BUFFER_FLAG_END_OF_STREAM
            )
            true
        } else {
            codec.queueInputBuffer(
                inputBufferIndex,
                0,
                sampleSize,
                extractor.sampleTime,
                0
            )

            extractor.advance()
            false
        }
    }

    private fun drainOutput(
        codec: MediaCodec,
        outputBufferIndex: Int,
        bufferInfo: MediaCodec.BufferInfo,
        outputStream: FileOutputStream
    ): Long {
        var written = 0L

        try {
            val outputBuffer = codec.getOutputBuffer(outputBufferIndex)

            if (outputBuffer != null && bufferInfo.size > 0) {
                val start = bufferInfo.offset
                val end = start + bufferInfo.size

                if (
                    start < 0 ||
                    bufferInfo.size < 0 ||
                    end > outputBuffer.capacity()
                ) {
                    throw IOException(
                        "MediaCodec devolvió un búfer PCM con límites inválidos."
                    )
                }

                outputBuffer.position(start)
                outputBuffer.limit(end)

                val pcmBytes = ByteArray(bufferInfo.size)
                outputBuffer.get(pcmBytes)

                outputStream.write(pcmBytes)
                written = pcmBytes.size.toLong()
            }
        } finally {
            codec.releaseOutputBuffer(outputBufferIndex, false)
        }

        return written
    }

    private class DecodeStats(
        var sampleRate: Int,
        var channels: Int,
        var bitsPerSample: Int,
        var totalPcmSize: Long = 0L
    ) {
        fun updateFrom(format: MediaFormat) {
            if (format.containsKey(MediaFormat.KEY_SAMPLE_RATE)) {
                sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
            }

            if (format.containsKey(MediaFormat.KEY_CHANNEL_COUNT)) {
                channels = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
            }

            if (format.containsKey(MediaFormat.KEY_PCM_ENCODING)) {
                bitsPerSample = when (
                    format.getInteger(MediaFormat.KEY_PCM_ENCODING)
                ) {
                    AudioFormat.ENCODING_PCM_8BIT -> 8
                    AudioFormat.ENCODING_PCM_16BIT -> 16
                    AudioFormat.ENCODING_PCM_24BIT_PACKED -> 24
                    AudioFormat.ENCODING_PCM_32BIT -> 32
                    else -> 16
                }
            }
        }
    }
}
