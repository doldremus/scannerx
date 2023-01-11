package dev.doldremus.scannerx

import android.content.pm.PackageManager
import android.util.Log
import com.google.mlkit.vision.barcode.common.Barcode as MLBarcode

val MLBarcode.toApiModel: RawBarcode
    get() = RawBarcode(
        corners = cornerPoints?.map { c -> BarcodeOffset(c.x.toDouble(), c.y.toDouble()) },
        boundingBox = if (boundingBox != null) BarcodeBoundingBox(
            left = boundingBox!!.left.toDouble(),
            top = boundingBox!!.top.toDouble(),
            right = boundingBox!!.right.toDouble(),
            bottom = boundingBox!!.left.toDouble(),
        ) else null,
        rawBytes = rawBytes,
        rawValue = rawValue,
        format = barcodeFormatFromRaw(format),
        type = BarcodeType.ofRaw(valueType),
    )

fun barcodeFormatFromRaw(format: Int): BarcodeFormat {
    when (format) {
        -1 -> return BarcodeFormat.UNKNOWN
        0 -> return BarcodeFormat.ALL
        1 -> return BarcodeFormat.CODE128
        2 -> return BarcodeFormat.CODE39
        4 -> return BarcodeFormat.CODE93
        8 -> return BarcodeFormat.CODEBAR
        16 -> return BarcodeFormat.DATAMATRIX
        32 -> return BarcodeFormat.EAN13
        64 -> return BarcodeFormat.EAN8
        128 -> return BarcodeFormat.ITF
        256 -> return BarcodeFormat.QRCODE
        512 -> return BarcodeFormat.UPCA
        1024 -> return BarcodeFormat.UPCE
        2048 -> return BarcodeFormat.PDF417
        4096 -> return BarcodeFormat.AZTEC
        else -> return BarcodeFormat.UNKNOWN
    }
}

fun logError(api: LoggerFlutterApi?, exception: Throwable) {
    val error = LoggerError(
        className = exception.javaClass.simpleName,
        cause = exception.cause.toString(),
        stackTrace = Log.getStackTraceString(exception),
        message = exception.message,
        isCritical = true,
    )

    api?.logError(error) {}
}

fun logMessage(api: LoggerFlutterApi?, message: String, logLevel: LogLevel = LogLevel.VERBOSE) {
    val msg = LoggerMessage(
        message = message,
        logLevel = logLevel
    )

    api?.logMessage(msg) {}
}

fun hasAllPermissionsGranted(grantResults: IntArray): Boolean {
    for (result in grantResults) {
        if (result == PackageManager.PERMISSION_DENIED) {
            return false
        }
    }
    return true
}