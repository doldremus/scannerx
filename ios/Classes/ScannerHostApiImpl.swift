import AVFoundation
import Flutter
import MLKitVision
import MLKitBarcodeScanning

public class ScannerHostApiImpl: NSObject, ScannerHostApi, FlutterTexture, AVCaptureVideoDataOutputSampleBufferDelegate {
    let barcodesApi: BarcodeFlutterApi
    let loggerApi: LoggerFlutterApi
    
    let textureRegistry: FlutterTextureRegistry
    
    var imageBuffer: CVImageBuffer!
    var textureId: Int64!
    var captureSession: AVCaptureSession!
    var captureDevice: AVCaptureDevice!
    var isCaptureOutputBusy: Bool
    
    init(_ registrar: FlutterPluginRegistrar) {
        barcodesApi = BarcodeFlutterApi(binaryMessenger: registrar.messenger())
        loggerApi = LoggerFlutterApi(binaryMessenger: registrar.messenger())
        
        textureRegistry = registrar.textures()
        
        isCaptureOutputBusy = false
        
        super.init()
    }

    public func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        if imageBuffer == nil {
            return nil
        }
        return Unmanaged<CVPixelBuffer>.passRetained(imageBuffer)
    }

    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        textureRegistry.textureFrameAvailable(textureId)

        if isCaptureOutputBusy {
            return
        }

        isCaptureOutputBusy = true

        let visionImage = VisionImage(image: imageBuffer.image)
//        visionImage.orientation = UIDevice.current.orientation.imageOrientation(position: captureDevice.position)

        let format = MLKitBarcodeScanning.BarcodeFormat.all
        let barcodeOptions = BarcodeScannerOptions(formats: format)
        let scanner = BarcodeScanner.barcodeScanner(options: barcodeOptions)
        
        scanner.process(visionImage) { [self] barcodes, error in
            guard error == nil else {
                logError(loggerApi, error)
                isCaptureOutputBusy = false
                return
            }
            
            if barcodes != nil {
                let convertedData = barcodes!.map { $0.toApiModel }
                barcodesApi.barcodes(barcodes: convertedData){}
            } else {
                barcodesApi.barcodes(barcodes: []) {}
            }

            isCaptureOutputBusy = false
        }
    }

    func requestPermissions(completion: @escaping (PermissionsResponse) -> Void) {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            completion(PermissionsResponse.init(granted: true, permanentlyDenied: false))
            return
        }
        AVCaptureDevice.requestAccess(for: .video) {
            completion(PermissionsResponse.init(granted: $0, permanentlyDenied: false))
        }
    }
    
    func initialize(options: ScannerOptions, completion: @escaping (RawScannerDescription?) -> Void) {
        requestPermissions() { [self] in
            guard $0.granted else {
                if($0.permanentlyDenied){
                    logError(loggerApi, ScannerHostApiError.cameraAccessDenied)
                }else{
                    logError(loggerApi, ScannerHostApiError.cameraAccessDenied)
                }
                completion(nil)
                return
            }
            
            initScanner(options: options, completion: completion)
        }
    }
    
    func initScanner(options: ScannerOptions, completion: @escaping (RawScannerDescription?) -> Void)  {
        textureId = textureRegistry.register(self)
        captureSession = AVCaptureSession()
        
        captureDevice = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: options.lensDirection == .front ? AVCaptureDevice.Position.front : .back
        ).devices.first
        
        captureSession.beginConfiguration()
//        captureSession.sessionPreset = AVCaptureSession.Preset.hd1280x720
        
        //add device input
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch let error {
            logError(loggerApi, error)
        }
        
        //add video output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        
        captureSession.addOutput(videoOutput)
        for connection in videoOutput.connections {
            connection.videoOrientation = .portrait
            if options.lensDirection == .front && connection.isVideoMirroringSupported {
                connection.isVideoMirrored = true
            }
        }
        captureSession.commitConfiguration()
        captureSession.startRunning()

        completion(createScannerDescription())
    }
    
    func createScannerDescription() -> RawScannerDescription? {
        guard captureDevice != nil else {
            logError(loggerApi, ScannerHostApiError.captureDeviceNotInitialized)
            return nil
        }
        
        let dimensions = CMVideoFormatDescriptionGetDimensions(captureDevice.activeFormat.formatDescription)
        
        let width = Double(dimensions.width)
        let height = Double(dimensions.height)
        let resolution = Resolution(width: height, height: width)
        let textureDescription = RawTextureDescription(id: Int32(truncatingIfNeeded: textureId), resolution: resolution)
        let analysisDescription = RawAnalysisDescription(resolution: resolution)
        
        return RawScannerDescription(
            texture: textureDescription,
            analysis: analysisDescription
        )
    }
    
    
    func dispose(completion: @escaping () -> Void) {
        if captureSession != nil {
            captureSession.stopRunning()
            for input in captureSession.inputs {
                captureSession.removeInput(input)
            }
            for output in captureSession.outputs {
                captureSession.removeOutput(output)
            }
        }

        textureRegistry.unregisterTexture(textureId)
        
        imageBuffer = nil
        captureSession = nil
        captureDevice = nil
        textureId = nil
        
        completion()
    }

    func hasFlashlight() -> Bool {
        guard captureDevice != nil else {
            logError(loggerApi, ScannerHostApiError.captureDeviceNotInitialized)
            return false
        }
        return captureDevice!.hasTorch && captureDevice.isTorchModeSupported(.on)
    }
    
    func getFlashlightState() -> Bool {
        guard captureDevice != nil else {
            logError(loggerApi, ScannerHostApiError.captureDeviceNotInitialized)
            return false
        }
        return captureDevice!.torchMode == .on ? true : false
    }
    
    func setFlashlightState(state: Bool) {
        guard captureDevice != nil else {
            logError(loggerApi, ScannerHostApiError.captureDeviceNotInitialized)
            return
        }
        guard captureDevice.isTorchModeSupported(.on) else {
            logError(loggerApi, ScannerHostApiError.torchModeUnsupported)
            return
        }
        do {
            try captureDevice!.lockForConfiguration()
            captureDevice!.torchMode = state ? .on : .off
            captureDevice!.unlockForConfiguration()
        } catch {
            logError(loggerApi, error)
        }
    }
}

enum ScannerHostApiError: Error {
    case captureDeviceNotInitialized
    case torchModeUnsupported
    case cameraAccessPermanentlyDenied
    case cameraAccessDenied
}
