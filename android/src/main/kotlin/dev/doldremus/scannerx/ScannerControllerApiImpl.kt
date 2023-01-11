package dev.doldremus.scannerx

import android.Manifest
import android.annotation.SuppressLint
import android.content.pm.PackageManager
import android.util.Size
import android.view.Surface
import androidx.camera.core.Camera
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.Preview
import androidx.camera.core.TorchState
import androidx.camera.core.UseCaseGroup
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.mlkit.vision.MlKitAnalyzer
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import com.google.mlkit.vision.barcode.BarcodeScanning
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry
import io.flutter.view.TextureRegistry
import java.util.concurrent.Executor

class ScannerHostApiImpl : ScannerHostApi, PluginRegistry.RequestPermissionsResultListener {
    companion object {
        private const val PERMISSIONS_REQUEST_CODE = 47474747
    }

    private var flutterBinding: FlutterPlugin.FlutterPluginBinding? = null
    private var activityBinding: ActivityPluginBinding? = null

    private var barcodesApi: BarcodeFlutterApi? = null
    private var loggerApi: LoggerFlutterApi? = null

    private var permissionsListener: PluginRegistry.RequestPermissionsResultListener? = null

    private var cameraProvider: ProcessCameraProvider? = null
    private var camera: Camera? = null
    private var textureEntry: TextureRegistry.SurfaceTextureEntry? = null

    fun onActivityInit(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding, activityPluginBinding: ActivityPluginBinding) {
        flutterBinding = flutterPluginBinding
        activityBinding = activityPluginBinding
        barcodesApi = BarcodeFlutterApi(flutterBinding!!.binaryMessenger)
        loggerApi = LoggerFlutterApi(flutterBinding!!.binaryMessenger)
    }

    fun onActivityDispose() {
        flutterBinding = null
        activityBinding = null
        barcodesApi = null
        loggerApi = null
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
        return permissionsListener?.onRequestPermissionsResult(requestCode, permissions, grantResults) ?: false
    }

    // TODO at the moment there is no check for a permanent denying
    override fun requestPermissions(callback: (PermissionsResponse) -> Unit) {
        permissionsListener = PluginRegistry.RequestPermissionsResultListener { requestCode, _, grantResults ->
            if (requestCode != PERMISSIONS_REQUEST_CODE) {
                false
            } else {
                activityBinding?.removeRequestPermissionsResultListener(this)
                permissionsListener = null

                if (hasAllPermissionsGranted(grantResults)) {
                    callback(PermissionsResponse(granted = true, permanentlyDenied = false))
                } else {
                    callback(PermissionsResponse(granted = false, permanentlyDenied = false))
                }

                true
            }
        }

        if (ActivityCompat.checkSelfPermission(activityBinding!!.activity, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
            callback(PermissionsResponse(granted = true, permanentlyDenied = false))
        } else {
            activityBinding!!.addRequestPermissionsResultListener(this)
            ActivityCompat.requestPermissions(activityBinding!!.activity, arrayOf(Manifest.permission.CAMERA), PERMISSIONS_REQUEST_CODE)
        }
    }

    override fun init(options: ScannerOptions, callback: (RawScannerDescription?) -> Unit) {
        requestPermissions {
            try {
                if (it.granted) {
                    initScanner(options, callback)
                } else {
                    if (it.permanentlyDenied) {
                        throw CameraAccessPermanentlyDenied()
                    } else {
                        throw CameraAccessDenied()
                    }
                }
            } catch (e: Throwable) {
                logError(loggerApi, e)
                callback(null)
            }
        }
    }

    private fun initScanner(options: ScannerOptions, callback: (RawScannerDescription?) -> Unit) {
        try {
            val cameraProviderFuture = ProcessCameraProvider.getInstance(activityBinding!!.activity)
            val executor = ContextCompat.getMainExecutor(activityBinding!!.activity)

            cameraProviderFuture.addListener({
                try {
                    cameraProvider = cameraProviderFuture.get()
                    textureEntry = flutterBinding!!.textureRegistry.createSurfaceTexture()

                    var targetResolution: Size? = null
                    if (options.targetResolution != null) {
                        targetResolution = Size(options.targetResolution.width.toInt(), options.targetResolution.height.toInt())
                    }

                    val preview = createPreview(executor, targetResolution)
                    val analysis = createImageAnalysis(executor, targetResolution)

                    camera = bindToLifecycle(options, preview, analysis)

                    callback(createScannerDescription(preview, analysis))
                } catch (e: Throwable) {
                    logError(loggerApi, e)
                    callback(null)
                }
            }, executor)
        } catch (e: Throwable) {
            logError(loggerApi, e)
            callback(null)
        }
    }

    private fun createPreview(executor: Executor, targetResolution: Size?): Preview {
        val surfaceProvider = Preview.SurfaceProvider { request ->
            val resolution = request.resolution
            val texture = textureEntry!!.surfaceTexture()
            texture.setDefaultBufferSize(resolution.width, resolution.height)
            val surface = Surface(texture)
            request.provideSurface(surface, executor) { }
        }

        val builder = Preview.Builder()
        if (targetResolution != null) builder.setTargetResolution(targetResolution)
        return builder.build().apply { setSurfaceProvider(surfaceProvider) }
    }

    private fun createImageAnalysis(executor: Executor, targetResolution: Size?): ImageAnalysis {
        val barcodeScanner = BarcodeScanning.getClient()
        val detectors = listOf(barcodeScanner)
        val analyzer = MlKitAnalyzer(detectors, ImageAnalysis.COORDINATE_SYSTEM_ORIGINAL, executor) {
            try {
                val barcodes = it.getValue(barcodeScanner)
                if (!barcodes.isNullOrEmpty()) {
                    val convertedData = barcodes.map { b -> b.toApiModel }
                    barcodesApi!!.barcodes(convertedData) {}
                } else {
                    barcodesApi!!.barcodes(emptyList()) {}
                }
            } catch (e: Throwable) {
                logError(loggerApi, e)
            }
        }

        val builder = ImageAnalysis.Builder()
        builder.setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
        if (targetResolution != null) builder.setTargetResolution(targetResolution)
        return builder.build().apply { setAnalyzer(executor, analyzer) }
    }

    private fun bindToLifecycle(options: ScannerOptions, preview: Preview, analysis: ImageAnalysis): Camera {
        val owner = activityBinding!!.activity as LifecycleOwner
        val selector =
            if (options.lensDirection == CameraLensDirection.FRONT) CameraSelector.DEFAULT_FRONT_CAMERA
            else CameraSelector.DEFAULT_BACK_CAMERA

        val useCaseGroup = UseCaseGroup.Builder()
            .addUseCase(preview)
            .addUseCase(analysis)
            .build()

        cameraProvider?.unbindAll()
        return cameraProvider!!.bindToLifecycle(owner, selector, useCaseGroup)
    }

    @SuppressLint("RestrictedApi")
    private fun createScannerDescription(preview: Preview, analysis: ImageAnalysis): RawScannerDescription {
        val portrait = camera!!.cameraInfo.sensorRotationDegrees % 180 == 0

        var resolution = preview.attachedSurfaceResolution!!
        var width = resolution.width.toDouble()
        var height = resolution.height.toDouble()

        val textureDescription =
            if (portrait) RawTextureDescription(textureEntry!!.id(), Resolution(width, height))
            else RawTextureDescription(textureEntry!!.id(), Resolution(height, width))

        resolution = analysis.attachedSurfaceResolution!!
        width = resolution.width.toDouble()
        height = resolution.height.toDouble()
        val analysisDescription =
            if (portrait) RawAnalysisDescription(Resolution(width, height))
            else RawAnalysisDescription(Resolution(height, width))

        return RawScannerDescription(textureDescription, analysisDescription)
    }

    override fun dispose(callback: () -> Unit) {
        cameraProvider?.unbindAll()
        textureEntry?.release()

        cameraProvider = null
        textureEntry = null
        camera = null

        callback()
    }

    override fun hasFlashlight(): Boolean {
        return try {
            camera!!.cameraInfo.hasFlashUnit()
        } catch (e: Throwable) {
            logError(loggerApi, e)
            false
        }
    }

    override fun getFlashlightState(): Boolean {
        return try {
            return camera!!.cameraInfo.torchState.value == TorchState.ON
        } catch (e: Throwable) {
            logError(loggerApi, e)
            false
        }
    }

    override fun setFlashlightState(state: Boolean) {
        try {
            camera!!.cameraControl.enableTorch(state)
        } catch (e: Throwable) {
            logError(loggerApi, e)
        }
    }
}

class CameraAccessDenied : Exception()
class CameraAccessPermanentlyDenied : Exception()