//android/app/src/main/kotlin/com/example/offline_music/media/WavHeaderWriter.kt
package com.example.offline_music.media

import java.io.File
import java.io.RandomAccessFile

internal object WavHeaderWriter {

    fun write(
        file: File,
        totalAudioLen: Long,
        sampleRate: Int,
        channels: Int,
        bitsPerSample: Int
    ) {
        val byteRate = sampleRate * channels * bitsPerSample / 8
        val blockAlign = channels * bitsPerSample / 8
        val totalDataLen = totalAudioLen + 36

        val header = buildHeader(
            totalDataLen = totalDataLen,
            totalAudioLen = totalAudioLen,
            sampleRate = sampleRate,
            channels = channels,
            bitsPerSample = bitsPerSample,
            byteRate = byteRate,
            blockAlign = blockAlign
        )

        RandomAccessFile(file, "rw").use { raf ->
            raf.seek(0)
            raf.write(header)
        }
    }

    private fun buildHeader(
        totalDataLen: Long,
        totalAudioLen: Long,
        sampleRate: Int,
        channels: Int,
        bitsPerSample: Int,
        byteRate: Int,
        blockAlign: Int
    ): ByteArray {
        val header = ByteArray(MediaConstants.WAV_HEADER_SIZE)

        header.writeAscii(0, "RIFF")
        header.writeIntLE(4, totalDataLen)
        header.writeAscii(8, "WAVE")
        header.writeAscii(12, "fmt ")
        header.writeIntLE(16, 16L)
        header.writeShortLE(20, 1)
        header.writeShortLE(22, channels)
        header.writeIntLE(24, sampleRate.toLong())
        header.writeIntLE(28, byteRate.toLong())
        header.writeShortLE(32, blockAlign)
        header.writeShortLE(34, bitsPerSample)
        header.writeAscii(36, "data")
        header.writeIntLE(40, totalAudioLen)

        return header
    }

    private fun ByteArray.writeAscii(offset: Int, value: String) {
        value.forEachIndexed { i, c -> this[offset + i] = c.code.toByte() }
    }

    private fun ByteArray.writeIntLE(offset: Int, value: Long) {
        this[offset] = (value and 0xff).toByte()
        this[offset + 1] = ((value shr 8) and 0xff).toByte()
        this[offset + 2] = ((value shr 16) and 0xff).toByte()
        this[offset + 3] = ((value shr 24) and 0xff).toByte()
    }

    private fun ByteArray.writeShortLE(offset: Int, value: Int) {
        this[offset] = (value and 0xff).toByte()
        this[offset + 1] = ((value shr 8) and 0xff).toByte()
    }
}
