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
    var isCaptureOutputBusy: Bool
    
    init(_ registrar: FlutterPluginRegistrar) {
        barcodesApi = BarcodeFlutterApi(binaryMessenger: registrar.messenger())
        loggerApi = LoggerFlutterApi(binaryMessenger: registrar.messenger())
        
        textureRegistry = registrar.textures()
        
        isCaptureOutputBusy = false
        
        super.init()
    }
    
    /**
     * FlutterTexture impl
     */
    public func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        if imageBuffer == nil {
            return nil
        }
        return Unmanaged<CVPixelBuffer>.passRetained(imageBuffer)
    }
    
    /**
     * AVCaptureVideoDataOutputSampleBufferDelegate
     */
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        textureRegistry.textureFrameAvailable(textureId)
        
        if isCaptureOutputBusy {
            return
        }
        
        isCaptureOutputBusy = true

        let image = VisionImage(buffer: sampleBuffer)
        let scanner = BarcodeScanner.barcodeScanner()
        scanner.process(image) { [self] barcodes, error in
            if error == nil {
                if barcodes != nil {
                    let convertedData = barcodes!.map{ $0.toApiModel }
                    barcodesApi.barcodes(barcodes: convertedData){}
                } else {
                    barcodesApi.barcodes(barcodes: []) {}
                }
            } else {
                logError(loggerApi, error)
            }
            
            isCaptureOutputBusy = false
        }
    }
    
    /**
     * ScannerHostApi impl
     */
    func requestPermissions(completion: @escaping (PermissionsResponse) -> Void) {
       
    }
    
    func initialize(options: ScannerOptions, completion: @escaping (RawScannerDescription?) -> Void) {
        
    }
    
    func dispose(completion: @escaping () -> Void) {
       
    }

    func hasFlashlight() -> Bool {
        return true
    }
    
    func getFlashlightState() -> Bool {
        return true
    }
    
    func setFlashlightState(state: Bool) {}
}
