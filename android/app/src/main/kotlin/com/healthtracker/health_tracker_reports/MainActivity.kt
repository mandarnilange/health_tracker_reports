package com.healthtracker.health_tracker_reports

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.pdf.PdfRenderer
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException
import java.util.Locale
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.TextRecognizer
import com.google.mlkit.vision.text.latin.TextRecognizerOptions

private const val REPORT_SCAN_METHOD_CHANNEL = "report_scan/methods"
private const val REPORT_SCAN_EVENT_CHANNEL = "report_scan/events"

class MainActivity : FlutterActivity() {
    private val reportScanHandler = ReportScanStreamHandler()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor.binaryMessenger
        EventChannel(messenger, REPORT_SCAN_EVENT_CHANNEL)
            .setStreamHandler(reportScanHandler)

        MethodChannel(messenger, REPORT_SCAN_METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startScan" -> {
                        reportScanHandler.start(call.arguments)
                        result.success(null)
                    }
                    "cancelScan" -> {
                        reportScanHandler.cancel()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}

private enum class ScanSource {
    PDF,
    IMAGES;

    companion object {
        fun from(value: String?): ScanSource? =
            when (value?.lowercase(Locale.ROOT)) {
                "pdf" -> PDF
                "images" -> IMAGES
                else -> null
            }
    }
}

private data class ScanRequest(
    val source: ScanSource,
    val uri: String,
    val imageUris: List<String>
) {
    fun primaryFilePath(): String = parseFilePath(uri)
    fun imagePaths(): List<String> {
        val targets = if (imageUris.isNotEmpty()) imageUris else listOf(uri)
        return targets.map(::parseFilePath)
    }

    companion object {
        fun from(arguments: Any?): ScanRequest? {
            val map = arguments as? Map<*, *> ?: return null
            val source = ScanSource.from(map["source"] as? String) ?: return null
            val uri = map["uri"] as? String ?: return null
            val imageUris = (map["imageUris"] as? List<*>)?.filterIsInstance<String>() ?: emptyList()
            return ScanRequest(source, uri, imageUris)
        }
    }
}

private fun parseFilePath(value: String): String {
    val uri = Uri.parse(value)
    return uri.path ?: value
}

private class ReportScanStreamHandler : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null
    private var pendingArguments: Any? = null
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private val mainHandler = Handler(Looper.getMainLooper())
    private var currentJob: Job? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        eventSink = events
        pendingArguments?.let {
            pendingArguments = null
            start(it)
        }
    }

    override fun onCancel(arguments: Any?) {
        cancel()
        eventSink = null
        pendingArguments = null
    }

    fun start(arguments: Any?) {
        val sink = eventSink
        if (sink == null) {
            pendingArguments = arguments
            return
        }

        val request = ScanRequest.from(arguments)
        if (request == null) {
            emit(
                mapOf(
                    "type" to "error",
                    "code" to "invalid_request",
                    "message" to "Invalid scan arguments"
                )
            )
            return
        }

        currentJob?.cancel()
        currentJob = scope.launch {
            try {
                when (request.source) {
                    ScanSource.PDF -> processPdf(request)
                    ScanSource.IMAGES -> processImages(request)
                }
                emit(mapOf("type" to "complete"))
            } catch (cancelled: CancellationException) {
                // Swallow cancellation.
            } catch (ex: Exception) {
                emit(
                    mapOf(
                        "type" to "error",
                        "code" to "scan_failed",
                        "message" to (ex.message ?: "Scanning failed")
                    )
                )
            }
        }
    }

    fun cancel() {
        currentJob?.cancel()
        currentJob = null
    }

    private suspend fun processPdf(request: ScanRequest) {
        val file = File(request.primaryFilePath())
        if (!file.exists()) {
            throw IOException("PDF not found at ${file.absolutePath}")
        }

        ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY).use { descriptor ->
            PdfRenderer(descriptor).use { renderer ->
                val total = renderer.pageCount
                val recognizer = createTextRecognizer()

                try {
                    for (index in 0 until total) {
                        ensureActive()
                        emit(
                            mapOf(
                                "type" to "progress",
                                "page" to index + 1,
                                "totalPages" to total
                            )
                        )

                        val page = renderer.openPage(index)
                        val width = page.width * 2
                        val height = page.height * 2
                        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                        try {
                            page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                            val text = recognizeText(bitmap, recognizer)
                            emitStructuredEvent(pageIndex = index + 1, totalPages = total, text = text)
                        } finally {
                            page.close()
                            bitmap.recycle()
                        }
                    }
                } finally {
                    recognizer.close()
                }
            }
        }
    }

    private suspend fun processImages(request: ScanRequest) {
        val paths = request.imagePaths()
        if (paths.isEmpty()) {
            throw IOException("No images supplied")
        }

        val recognizer = createTextRecognizer()
        try {
            for ((index, path) in paths.withIndex()) {
                ensureActive()
                val bitmap = BitmapFactory.decodeFile(path) ?: continue
                try {
                    val text = recognizeText(bitmap, recognizer)
                    emit(
                        mapOf(
                            "type" to "progress",
                            "page" to index + 1,
                            "totalPages" to paths.size
                        )
                    )
                    emitStructuredEvent(pageIndex = index + 1, totalPages = paths.size, text = text)
                } finally {
                    bitmap.recycle()
                }
            }
        } finally {
            recognizer.close()
        }
    }

    private fun createTextRecognizer(): TextRecognizer =
        TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)

    private suspend fun recognizeText(
        bitmap: Bitmap,
        recognizer: TextRecognizer
    ): String = suspendCancellableCoroutine { continuation ->
        val image = InputImage.fromBitmap(bitmap, 0)
        recognizer.process(image)
            .addOnSuccessListener { result ->
                continuation.resume(result.text)
            }
            .addOnFailureListener { error ->
                if (continuation.isActive) {
                    continuation.resumeWithException(error)
                }
            }
            .addOnCanceledListener {
                if (continuation.isActive) {
                    continuation.cancel()
                }
            }
    }

    private fun emitStructuredEvent(pageIndex: Int, totalPages: Int, text: String) {
        val biomarkers = parseBiomarkers(text)
        emit(
            mapOf(
                "type" to "structured",
                "page" to pageIndex,
                "totalPages" to totalPages,
                "payload" to mapOf(
                    "rawText" to text,
                    "biomarkers" to biomarkers
                )
            )
        )
    }

    private fun parseBiomarkers(rawText: String): List<Map<String, Any?>> {
        val results = mutableListOf<Map<String, Any?>>()
        val valuePattern = Regex(
            "^\\s*([A-Za-z][A-Za-z0-9 .%/µ×^()+'\\-]+?)(?:\\s*[:\\-]\\s*)?([+\\-]?\\d+(?:[.,]\\d+)?)(.*)$",
            RegexOption.IGNORE_CASE
        )
        val rangePattern = Regex("([+\\-]?\\d+(?:[.,]\\d+)?)\\s*[-–]\\s*([+\\-]?\\d+(?:[.,]\\d+)?)")
        val metadataKeywords = listOf(
            "patient",
            "bill",
            "collected",
            "report",
            "release",
            "specimen",
            "registration",
            "lab",
            "ref",
            "uhid",
            "doctor",
            "hospital",
            "age",
            "gender",
            "date",
            "method",
            "processing",
            "session"
        )

        rawText.lines().forEach { line ->
            val trimmed = line.trim()
            if (trimmed.length < 3) return@forEach

            val match = valuePattern.find(trimmed) ?: return@forEach
            val name = match.groupValues[1].trim()
            if (name.isEmpty()) return@forEach

            val lowerName = name.lowercase(Locale.ROOT)
            if (metadataKeywords.any { lowerName.contains(it) }) return@forEach

            val value = match.groupValues[2].trim()
            val numericValue = value.replace(',', '.')
            numericValue.toDoubleOrNull() ?: return@forEach

            var remainder = match.groupValues.getOrNull(3)?.trim().orEmpty()
            var referenceMin: String? = null
            var referenceMax: String? = null

            rangePattern.find(remainder)?.let { rangeMatch ->
                referenceMin = rangeMatch.groupValues[1]
                referenceMax = rangeMatch.groupValues[2]
                val start = rangeMatch.range.first
                val end = rangeMatch.range.last + 1
                remainder = (remainder.substring(0, start) + " " + remainder.substring(end)).trim()
            }

            var sanitizedUnit = remainder.trim().trim { it == '-' || it == ' ' }
            if (sanitizedUnit.isNotEmpty()) {
                sanitizedUnit = sanitizedUnit.replace(Regex("\\s+"), " ")
            }

            val hasMeasurementChars =
                sanitizedUnit.any { it.isLetter() } || sanitizedUnit.any { "%/µxX^".contains(it) }

            if (sanitizedUnit.isEmpty() && referenceMin == null) return@forEach
            if (referenceMin == null && !hasMeasurementChars) return@forEach

            val biomarker = mutableMapOf<String, Any?>(
                "name" to name,
                "value" to value
            )

            if (sanitizedUnit.isNotEmpty()) {
                biomarker["unit"] = sanitizedUnit
            }
            referenceMin?.let { biomarker["referenceMin"] = it }
            referenceMax?.let { biomarker["referenceMax"] = it }

            results.add(biomarker)
        }

        return results
    }

    private fun emit(data: Map<String, Any?>) {
        mainHandler.post {
            eventSink?.success(data)
        }
    }
}
