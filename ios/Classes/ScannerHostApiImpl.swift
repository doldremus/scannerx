import AVFoundation
import Flutter
import MLKitVision
import MLKitBarcodeScanning

public class ScannerHostApiImpl: NSObject, ScannerHostApi, FlutterTexture, AVCaptureVideoDataOutputSampleBufferDelegate {
    let barcodesApi: BarcodeFlutterApi
    let loggerApi: LoggerFlutterApi
    
    let textureRegistry: FlutterTextureRegistry
    
    var imageBuffer: CVImageBuffer?
    var textureId: Int64?
    var captureSession: AVCaptureSession?
    var captureDevice: AVCaptureDevice?
    var isCaptureOutputBusy: Bool
    var isInverseColors: Bool
    
    init(_ registrar: FlutterPluginRegistrar) {
        barcodesApi = BarcodeFlutterApi(binaryMessenger: registrar.messenger())
        loggerApi = LoggerFlutterApi(binaryMessenger: registrar.messenger())
        
        textureRegistry = registrar.textures()
        
        isCaptureOutputBusy = false
        isInverseColors = false
        
        super.init()
    }

    public func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        if imageBuffer == nil {
            return nil
        }
        return Unmanaged<CVPixelBuffer>.passRetained(imageBuffer!)
    }

    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        guard imageBuffer != nil else {
            logError(loggerApi, ScannerHostApiError.ImageBufferIsNull)
            return
        }
        guard textureId != nil else {
            logError(loggerApi, ScannerHostApiError.TextureIdIsNull)
            return
        }
        
        textureRegistry.textureFrameAvailable(textureId!)

        guard !isCaptureOutputBusy else {
            return
        }

        isCaptureOutputBusy = true
        isInverseColors = !isInverseColors
        
        var image: UIImage?
        if isInverseColors {
            image = imageBuffer!.inverseImage()
        }
        if image?.cgImage == nil {
            image = imageBuffer!.image
        }

        let visionImage = VisionImage(image: image!)
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
        let mediaType = AVMediaType.video
        let status = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch status {
            case .denied, .restricted: completion(PermissionsResponse(granted: false, permanentlyDenied: true))
            case .authorized: completion(PermissionsResponse(granted: true, permanentlyDenied: false))
            default:
                AVCaptureDevice.requestAccess(for: mediaType) { granted in
                    completion(PermissionsResponse(granted: granted, permanentlyDenied: false))
                }
        }
    }
        
    func initialize(options: ScannerOptions, completion: @escaping (RawScannerDescription?) -> Void) {
        requestPermissions() { [self] result in
            guard result.granted else {
                if(result.permanentlyDenied) {
                    logError(loggerApi, ScannerHostApiError.CameraAccessPermanentlyDenied)
                } else {
                    logError(loggerApi, ScannerHostApiError.CameraAccessDenied)
                }
                completion(nil)
                return
            }
            self.initScanner(options: options, completion: completion)
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

        guard captureDevice != nil else {
            logError(loggerApi, ScannerHostApiError.SuitableDeviceNotFound)
            return
        }

        captureSession!.beginConfiguration()
        captureSession!.sessionPreset = AVCaptureSession.Preset.hd1280x720
        
        //add device input
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession!.addInput(input)
            setRecommendedZoomFactor(videoDeviceInput: input);
        } catch let error {
            logError(loggerApi, error)
        }
        
        //add video output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        
        captureSession!.addOutput(videoOutput)
        for connection in videoOutput.connections {
            connection.videoOrientation = .portrait
            if options.lensDirection == .front && connection.isVideoMirroringSupported {
                connection.isVideoMirrored = true
            }
        }
        
        captureSession!.commitConfiguration()
        captureSession!.startRunning()

        completion(createScannerDescription())
    }
    
    func setRecommendedZoomFactor(videoDeviceInput: AVCaptureDeviceInput) {
        /*
            Optimize the user experience for scanning QR codes down to sizes of 20mm x 20mm.
            When scanning a QR code of that size, the user may need to get closer than the camera's minimum focus distance to fill the rect of interest.
            To have the QR code both fill the rect and still be in focus, we may need to apply some zoom.
        */
        if #available(iOS 15.0, *) {
            let minimumCodeSize : Float = 70.0;
            let rectOfInterestWidth : Float = 1.0;
            let deviceMinimumFocusDistance = Float(videoDeviceInput.device.minimumFocusDistance)
            guard deviceMinimumFocusDistance != -1 else { return }
            
            let deviceFieldOfView = videoDeviceInput.device.activeFormat.videoFieldOfView
            let minimumSubjectDistanceForCode = minimumSubjectDistanceForCode(fieldOfView: deviceFieldOfView,
                                                                              minimumCodeSize: minimumCodeSize,
                                                                              previewFillPercentage: rectOfInterestWidth)
            if minimumSubjectDistanceForCode < deviceMinimumFocusDistance {
                let zoomFactor = deviceMinimumFocusDistance / minimumSubjectDistanceForCode
                do {
                    try videoDeviceInput.device.lockForConfiguration()
                    videoDeviceInput.device.videoZoomFactor = CGFloat(zoomFactor)
                    videoDeviceInput.device.unlockForConfiguration()
                } catch {
                    print("Could not lock for configuration: \(error)")
                }
            }
        }
    }
    
    private func minimumSubjectDistanceForCode(fieldOfView: Float, minimumCodeSize: Float, previewFillPercentage: Float) -> Float {
        /*
            Given the camera horizontal field of view, we can compute the distance (mm) to make a code
            of minimumCodeSize (mm) fill the previewFillPercentage.
         */
        let radians = degreesToRadians(fieldOfView / 2)
        let filledCodeSize = minimumCodeSize / previewFillPercentage
        return filledCodeSize / tan(radians)
    }
    
    private func degreesToRadians(_ degrees: Float) -> Float {
        return degrees * Float.pi / 180
    }
    
    func createScannerDescription() -> RawScannerDescription? {
        guard captureDevice != nil else {
            logError(loggerApi, ScannerHostApiError.CaptureDeviceIsNull)
            return nil
        }
        guard textureId != nil else {
            logError(loggerApi, ScannerHostApiError.TextureIdIsNull)
            return nil
        }
        
        let dimensions = CMVideoFormatDescriptionGetDimensions(captureDevice!.activeFormat.formatDescription)
        
        let width = Double(dimensions.width)
        let height = Double(dimensions.height)
        let resolution = Resolution(width: height, height: width)
        let textureDescription = RawTextureDescription(id: Int32(truncatingIfNeeded: textureId!), resolution: resolution)
        let analysisDescription = RawAnalysisDescription(resolution: resolution)
        
        return RawScannerDescription(
            texture: textureDescription,
            analysis: analysisDescription
        )
    }
    
    
    func dispose(completion: @escaping () -> Void) {
        if captureSession != nil {
            captureSession!.stopRunning()
            for input in captureSession!.inputs {
                captureSession!.removeInput(input)
            }
            for output in captureSession!.outputs {
                captureSession!.removeOutput(output)
            }
        }

        if textureId != nil {
            textureRegistry.unregisterTexture(textureId!)
        }
        
        imageBuffer = nil
        captureSession = nil
        captureDevice = nil
        textureId = nil
        
        completion()
    }

    func hasFlashlight() -> Bool {
        guard captureDevice != nil else {
            logError(loggerApi, ScannerHostApiError.CaptureDeviceIsNull)
            return false
        }
        return captureDevice!.hasTorch && captureDevice!.isTorchModeSupported(.on)
    }
    
    func getFlashlightState() -> Bool {
        guard captureDevice != nil else {
            logError(loggerApi, ScannerHostApiError.CaptureDeviceIsNull)
            return false
        }
        return captureDevice!.torchMode == .on ? true : false
    }
    
    func setFlashlightState(state: Bool) {
        guard captureDevice != nil else {
            logError(loggerApi, ScannerHostApiError.CaptureDeviceIsNull)
            return
        }
        guard captureDevice!.isTorchModeSupported(.on) else {
            logError(loggerApi, ScannerHostApiError.TorchModeUnsupported)
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
    case CaptureDeviceIsNull
    case SuitableDeviceNotFound
    case ImageBufferIsNull
    case TextureIdIsNull
    case TorchModeUnsupported
    case CameraAccessPermanentlyDenied
    case CameraAccessDenied
}
