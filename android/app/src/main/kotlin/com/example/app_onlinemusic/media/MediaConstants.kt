//android/app/src/main/kotlin/com/example/offline_music/media/MediaConstants.kt
package com.example.offline_music.media

internal object MediaConstants {
    // Canal de comunicación Flutter ↔ Android.
    const val CHANNEL = "offline_music/media"

    // Métodos del canal.
    const val METHOD_SCAN = "scan"
    const val METHOD_CONVERT = "convertAudioToWav"
    const val METHOD_GET_AUDIO_MIME = "getAudioMimeType"
    const val METHOD_IS_DECODER_AVAILABLE = "isAudioDecoderAvailable"
    const val METHOD_GET_ARTWORK = "getAudioArtwork"
    const val METHOD_GET_CACHE_PATHS = "getCachePaths"

    // Argumentos de los métodos.
    const val ARG_PATH = "path"
    const val ARG_OUTPUT_PATH = "outputPath"

    // Códigos de error.
    const val ERROR_INVALID_PATH = "INVALID_PATH"
    const val ERROR_SCAN_FAILED = "SCAN_FAILED"
    const val ERROR_MIME_NOT_FOUND = "MIME_NOT_FOUND"
    const val ERROR_MIME_DETECTION_FAILED = "MIME_DETECTION_FAILED"
    const val ERROR_DECODER_CHECK_FAILED = "DECODER_CHECK_FAILED"
    const val ERROR_CONVERSION_FAILED = "CONVERSION_FAILED"
    const val ERROR_ARTWORK_FAILED = "ARTWORK_FAILED"

    // Tipos MIME.
    const val AUDIO_MIME_PREFIX = "audio/"
    const val FALLBACK_MIME = "application/octet-stream"

    // Etiquetas.
    const val UNKNOWN_LABEL = "Desconocido"

    // Valores predeterminados del audio.
    const val DEFAULT_SAMPLE_RATE = 44100
    const val DEFAULT_CHANNELS = 2
    const val DEFAULT_BITS_PER_SAMPLE = 16

    // Conversión WAV.
    const val WAV_HEADER_SIZE = 44
    const val CODEC_TIMEOUT_US = 10_000L
    const val MAX_IDLE_ITERATIONS = 10_000
}
