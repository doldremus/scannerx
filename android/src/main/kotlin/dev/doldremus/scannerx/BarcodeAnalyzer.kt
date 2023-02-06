package dev.doldremus.scannerx

import android.graphics.ImageFormat
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
import com.google.mlkit.vision.common.internal.ImageConvertUtils
import java.nio.ByteBuffer
import java.util.concurrent.Executor
import kotlin.experimental.xor

class BarcodeAnalyzer(
    private val executor: Executor,
    private val loggerApi: LoggerFlutterApi?,
    private val listener: (List<Barcode>) -> Unit,
) : ImageAnalysis.Analyzer {
    private val recognizerOptions = BarcodeScannerOptions.Builder().setExecutor(executor).build()
    private val recognizer = BarcodeScanning.getClient(recognizerOptions)
    private var isInvertColors = false


    @androidx.camera.core.ExperimentalGetImage
    override fun analyze(imageProxy: ImageProxy) {
        val mediaImage = imageProxy.image

        if (mediaImage == null) {
            complete(imageProxy, BarcodesAnalyzerImageIsNull(), null)
            return
        }

        val thread = CreateBitmapThread(imageProxy, mediaImage, isInvertColors) { image ->
            executor.execute {
                isInvertColors = !isInvertColors

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

    override fun getDefaultTargetResolution(): Size? {
        return Size(1280, 720)
//        return Size(720, 1280)
    }
}

class CreateBitmapThread(
    private val imageProxy: ImageProxy,
    private val image: Image,
    private val isInvertColors: Boolean,
    private val done: (InputImage) -> Unit,
) : Thread() {
    override fun run() {
        val transform = Matrix()
        val rotationDegrees = imageProxy.imageInfo.rotationDegrees

        var inputImage = InputImage.fromMediaImage(image, rotationDegrees, transform)
        if (isInvertColors) {
//            val bitmap = ImageConvertUtils.getInstance().getUpRightBitmap(inputImage)
//            ImageConvertUtils.getInstance().convertToNv21Buffer(inputImage, false)
//            val size = bitmap.width * bitmap.height
//            val pixels = IntArray(size)
//            bitmap.getPixels(pixels, 0, bitmap.width, 0, 0, bitmap.width, bitmap.height)
//            for(i in 0 until  size){
//                pixels[i] = pixels[i] xor 0x00ffffff
//            }
//            bitmap.setPixels(pixels, 0, bitmap.width, 0, 0, bitmap.width, bitmap.height)
//            inputImage = InputImage.fromBitmap(bitmap, 0)

            val byteBuffer = ImageConvertUtils.getInstance().convertToNv21Buffer(inputImage, false)
            byteBuffer.rewind()
            val copyByteBuffer: ByteBuffer = ByteBuffer.allocate(byteBuffer.capacity())
            while (byteBuffer.hasRemaining()){
                copyByteBuffer.put(byteBuffer.get().xor(0xFF.toByte()))
            }
            inputImage = InputImage.fromByteBuffer(copyByteBuffer, inputImage.width, inputImage.height, rotationDegrees, ImageFormat.NV21)
        }

        done(inputImage)
    }
}

class BarcodesAnalyzerImageIsNull : Exception()
class BarcodesAnalyzerFailedToProcessImage : Exception()
class BarcodesAnalyzerTaskIsCanceled : Exception()