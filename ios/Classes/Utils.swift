import AVFoundation
import MLKitBarcodeScanning

extension CVBuffer {
    var image: UIImage {
        let ciImage = CIImage(cvPixelBuffer: self)
        let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent)
        return UIImage(cgImage: cgImage!)
    }
}

extension UIDeviceOrientation {
    func imageOrientation(position: AVCaptureDevice.Position) -> UIImage.Orientation {
        switch self {
        case .portrait:
            return position == .front ? .leftMirrored : .right
        case .landscapeLeft:
            return position == .front ? .downMirrored : .up
        case .portraitUpsideDown:
            return position == .front ? .rightMirrored : .left
        case .landscapeRight:
            return position == .front ? .upMirrored : .down
        default:
            return .up
        }
    }
}

extension Barcode {
    var toApiModel: RawBarcode {
        return RawBarcode(
            corners: cornerPoints?.map { BarcodeOffset(x: $0.cgPointValue.x, y: $0.cgPointValue.y) },
            boundingBox: nil,
            rawBytes: rawData != nil ? FlutterStandardTypedData.init(bytes: rawData!) : nil,
            rawValue: rawValue,
            format: format.toApiBarcodeFormat(),
            type: BarcodeType.init(rawValue: valueType.rawValue)
        )
    }
}

extension MLKitBarcodeScanning.BarcodeFormat {
    func toApiBarcodeFormat() -> BarcodeFormat {
        switch self.rawValue {
        case -1:
            return BarcodeFormat.unknown
        case 0:
            return BarcodeFormat.all
        case 1:
            return BarcodeFormat.code128
        case 2:
            return BarcodeFormat.code39
        case 4:
            return BarcodeFormat.code93
        case 8:
            return BarcodeFormat.codebar
        case 16:
            return BarcodeFormat.dataMatrix
        case 32:
            return BarcodeFormat.ean13
        case 64:
            return BarcodeFormat.ean8
        case 128:
            return BarcodeFormat.itf
        case 256:
            return BarcodeFormat.qrCode
        case 512:
            return BarcodeFormat.upcA
        case 1024:
            return BarcodeFormat.upcE
        case 2048:
            return BarcodeFormat.pdf417
        case 4096:
            return BarcodeFormat.aztec
        default:
            return BarcodeFormat.unknown
        }
    }
}

func logError(_ api: LoggerFlutterApi?, _ error: Error?){
    let error = LoggerError(
        className: error?.localizedDescription,
        stackTrace: Thread.callStackSymbols.joined(separator: "\n"),
        isCritical: true
    )
    
    api?.logError(error: error) {}
}

func logMessage(_ api: LoggerFlutterApi?, _ message: String, logLevel: LogLevel = LogLevel.verbose){
    let msg = LoggerMessage(
        message: message,
        logLevel: logLevel
    )
    
    api?.logMessage(message: msg) {}
}
