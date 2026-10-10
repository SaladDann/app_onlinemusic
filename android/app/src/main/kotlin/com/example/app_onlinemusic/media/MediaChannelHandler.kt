//android/app/src/main/kotlin/com/example/offline_music/media/MediaChannelHandler.kt
package com.example.offline_music.media

import android.content.Context
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.RejectedExecutionException

internal class MediaChannelHandler(
    private val context: Context,
    private val runOnUiThread: (Runnable) -> Unit
) : MethodChannel.MethodCallHandler {

    private val executor: ExecutorService =
        Executors.newCachedThreadPool { runnable ->
            Thread(runnable).apply {
                isDaemon = true
            }
        }

    private val scanner = AudioScanner(context.contentResolver)
    private val converter = AudioWavConverter(context.cacheDir)
    private val artworkExtractor = ArtworkExtractor(context.cacheDir)

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        when (call.method) {
            MediaConstants.METHOD_SCAN ->
                handleScan(result)

            MediaConstants.METHOD_GET_AUDIO_MIME ->
                handleGetMime(call, result)

            MediaConstants.METHOD_IS_DECODER_AVAILABLE ->
                handleDecoderCheck(call, result)

            MediaConstants.METHOD_CONVERT ->
                handleConvert(call, result)

            MediaConstants.METHOD_GET_ARTWORK ->
                handleGetArtwork(call, result)

            MediaConstants.METHOD_GET_CACHE_PATHS ->
                handleGetCachePaths(result)

            else ->
                result.notImplemented()
        }
    }

    fun shutdown() {
        try {
            executor.shutdownNow()
        } catch (_: Exception) {}
    }

    private fun safeExecute(result: MethodChannel.Result, errorCode: String, task: () -> Unit) {
        try {
            executor.execute {
                try {
                    task()
                } catch (e: Exception) {
                    postError(result, errorCode, e.localizedMessage ?: "Error en ejecución en segundo plano.")
                }
            }
        } catch (e: RejectedExecutionException) {
            postError(result, errorCode, "El servicio ejecutor fue rechazado o finalizado: ${e.localizedMessage}")
        }
    }

    private fun handleScan(result: MethodChannel.Result) {
        safeExecute(result, MediaConstants.ERROR_SCAN_FAILED) {
            val songs = scanner.scan()
            runOnUiThread {
                result.success(songs)
            }
        }
    }

    private fun handleGetMime(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val path = call.argument<String>(MediaConstants.ARG_PATH)
        if (!validatePath(path, result)) return

        safeExecute(result, MediaConstants.ERROR_MIME_DETECTION_FAILED) {
            val mime = AudioMimeDetector.detect(path!!)
            runOnUiThread {
                if (!mime.isNullOrBlank()) {
                    result.success(mime)
                } else {
                    result.error(
                        MediaConstants.ERROR_MIME_NOT_FOUND,
                        "No se encontró una pista de audio válida.",
                        null
                    )
                }
            }
        }
    }

    private fun handleDecoderCheck(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val path = call.argument<String>(MediaConstants.ARG_PATH)
        if (!validatePath(path, result)) return

        safeExecute(result, MediaConstants.ERROR_DECODER_CHECK_FAILED) {
            val info = AudioDecoderChecker.check(path!!)
            runOnUiThread {
                result.success(
                    mapOf(
                        "available" to info.available,
                        "mimeType" to (info.mimeType ?: ""),
                        "reason" to info.reason
                    )
                )
            }
        }
    }

    private fun handleConvert(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val inputPath = call.argument<String>(MediaConstants.ARG_PATH)
        if (!validatePath(inputPath, result)) return

        val outputPath = call.argument<String>(MediaConstants.ARG_OUTPUT_PATH)
        if (outputPath != null && outputPath.isBlank()) {
            result.error(
                MediaConstants.ERROR_INVALID_PATH,
                "La ruta de salida está vacía.",
                null
            )
            return
        }

        safeExecute(result, MediaConstants.ERROR_CONVERSION_FAILED) {
            val converted = converter.convert(
                inputPath = inputPath!!,
                outputPath = outputPath
            )
            runOnUiThread {
                result.success(converted)
            }
        }
    }

    private fun handleGetArtwork(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val path = call.argument<String>(MediaConstants.ARG_PATH)
        if (!validatePath(path, result)) return

        safeExecute(result, MediaConstants.ERROR_ARTWORK_FAILED) {
            val artworkPath = artworkExtractor.extract(path!!)
            runOnUiThread {
                result.success(artworkPath ?: "")
            }
        }
    }

    private fun handleGetCachePaths(
        result: MethodChannel.Result
    ) {
        runOnUiThread {
            result.success(
                mapOf(
                    "appCache" to artworkExtractor.appCacheDirPath(),
                    "artwork" to artworkExtractor.artworkCacheDirPath(),
                    "alac" to artworkExtractor.alacCacheDirPath()
                )
            )
        }
    }

    private fun validatePath(
        path: String?,
        result: MethodChannel.Result
    ): Boolean {
        if (path.isNullOrBlank()) {
            result.error(
                MediaConstants.ERROR_INVALID_PATH,
                "La ruta del archivo es nula o está vacía.",
                null
            )
            return false
        }
        return true
    }

    private fun postError(
        result: MethodChannel.Result,
        code: String,
        message: String
    ) {
        runOnUiThread {
            try {
                result.error(code, message, null)
            } catch (_: Exception) {}
        }
    }
}
