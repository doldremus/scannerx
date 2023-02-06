package dev.doldremus.scannerx

import android.graphics.Matrix
import android.media.Image
import android.util.Size
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import com.google.android.gms.tasks.Task
import com.google.mlkit.vision.barcode.BarcodeScannerOptions
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.common.InputImage
import java.util.concurrent.Executor

class BarcodeAnalyzer(
    private val executor: Executor,
    private val loggerApi: LoggerFlutterApi?,
    private val listener: (List<Barcode>) -> Unit,
) : ImageAnalysis.Analyzer {
    private val recognizerOptions = BarcodeScannerOptions.Builder().setExecutor(executor).build()
    private val recognizer = BarcodeScanning.getClient(recognizerOptions)
    private var isInverseColors = false


    @androidx.camera.core.ExperimentalGetImage
    override fun analyze(imageProxy: ImageProxy) {
        val mediaImage = imageProxy.image

        if (mediaImage == null) {
            complete(imageProxy, BarcodesAnalyzerImageIsNull(), null)
            return
        }

        val thread = CreateBitmapThread(imageProxy, mediaImage, isInverseColors) { image ->
            executor.execute {
                isInverseColors = !isInverseColors

                val task: Task<List<Barcode>>
                try {
                    task = recognizer.process(image)
                } catch (e: Throwable) {
                    complete(imageProxy, BarcodesAnalyzerFailedToProcessImage(), null)
                    return@execute
                }
                task.addOnCompleteListener {
                    if (it.isSuccessful) {
                        complete(imageProxy, null, it.result)
                    } else {
                        complete(imageProxy, BarcodesAnalyzerTaskIsCanceled(), null)
                    }
                }
            }
        }
        thread.priority = 1
        thread.start()
    }

    private fun complete(imageProxy: ImageProxy, exception: Exception?, result: List<Barcode>?) {
        imageProxy.close()

        if (exception != null) {
            logError(loggerApi, exception)
        }

        if (result != null) {
            listener(result)
        }
    }

    override fun getDefaultTargetResolution(): Size {
        return Size(720, 1280)
    }
}

class CreateBitmapThread(
    private val imageProxy: ImageProxy,
    private val image: Image,
    private val isInverseColors: Boolean,
    private val done: (InputImage) -> Unit,
) : Thread() {
    override fun run() {
        val transform = Matrix()
        val rotationDegrees = imageProxy.imageInfo.rotationDegrees

        var inputImage = InputImage.fromMediaImage(image, rotationDegrees, transform)
        if (isInverseColors) {
            val newImage = inverseColors(inputImage, rotationDegrees)
            if(newImage != null) inputImage = newImage
        }

        done(inputImage)
    }
}

class BarcodesAnalyzerImageIsNull : Exception()
class BarcodesAnalyzerFailedToProcessImage : Exception()
class BarcodesAnalyzerTaskIsCanceled : Exception()