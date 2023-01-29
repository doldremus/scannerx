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
                let convertedData = barcodes!.map{ $0.toApiModel }
                barcodesApi.barcodes(barcodes: convertedData){}
            } else {
                barcodesApi.barcodes(barcodes: []) {}
            }

            isCaptureOutputBusy = false
        }
    }
    
    /**
     * ScannerHostApi impl
     */
    func requestPermissions(completion: @escaping (PermissionsResponse) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) {
            completion(PermissionsResponse.init(
                granted: $0,
                permanentlyDenied: false
            ))
        }
    }
    
    func initialize(options: ScannerOptions, completion: @escaping (RawScannerDescription?) -> Void) {
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
        
        let dimensions = CMVideoFormatDescriptionGetDimensions(captureDevice.activeFormat.formatDescription)
        
        let width = Double(dimensions.width)
        let height = Double(dimensions.height)
        let resolution = width < height ? Resolution(width: width, height: height) : Resolution(width: height, height: width)
        let textureDescription = RawTextureDescription(id: Int32(truncatingIfNeeded: textureId), resolution: resolution)
        let analysisDescription = RawAnalysisDescription(resolution: resolution)
        completion(RawScannerDescription(
            texture: textureDescription,
            analysis: analysisDescription
        ))
    }
    
    func dispose(completion: @escaping () -> Void) {
        captureSession.stopRunning()
        for input in captureSession.inputs {
            captureSession.removeInput(input)
        }
        for output in captureSession.outputs {
            captureSession.removeOutput(output)
        }
        textureRegistry.unregisterTexture(textureId)
        
        imageBuffer = nil
        captureSession = nil
        captureDevice = nil
        textureId = nil
        
        completion()
    }

    func hasFlashlight() -> Bool {
        if(captureDevice != nil){
            return captureDevice!.hasTorch
        }
        return false
    }
    
    func getFlashlightState() -> Bool {
        if(captureDevice != nil){
            return captureDevice!.torchMode == .on ? true : false
        }
        return false
    }
    
    func setFlashlightState(state: Bool) {
        do {
            try captureDevice?.lockForConfiguration()
            captureDevice?.torchMode = state ? .on : .off
            captureDevice?.unlockForConfiguration()
        } catch let error {
            logError(loggerApi, error)
        }
    }
}
