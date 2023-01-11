import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scannerx/scannerx.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  ScannerPageState createState() => ScannerPageState();
}

class ScannerPageState extends State<ScannerPage> with SingleTickerProviderStateMixin {
  late ScannerController scannerController = ScannerController(onPlatformError: onPlatformError);
  bool redirecting = false;
  bool flashLightState = false;

  String lastBarcode = '';
  Timer? timerToClearLastBarcode;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    final description = await scannerController.init();
    if(description != null){
      // await scannerController.init(options: ScannerOptions(targetResolution: Resolution(width: 720, height: 1280)));
      flashLightState = await scannerController.getFlashlightState();
    }
  }

  @override
  void dispose() async {
    super.dispose();
    scannerController.dispose();
  }

  onPlatformError(ScannerError error) {
    switch (error.className) {
      case 'CameraAccessDenied':
      case 'CameraAccessPermanentlyDenied':
        Navigator.of(context).pop();
        break;
      default:
        // TODO implement unexpected error handling
    }
  }

  void showInfo(RawBarcode barcode) {
    if (!redirecting) {
      Navigator.of(context).popAndPushNamed('info', arguments: barcode);
      redirecting = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Scanner(
            controller: scannerController,
            loader: const Center(child: CircularProgressIndicator()),
            childBuilder: (description) {
              return BarcodeDetector(
                description: description,
                barcodesStream: scannerController.barcodes,
                drawDebug: true,
                onDetected: (barcodes) => onDetected(context, barcodes),
              );
            },
          ),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  left: 12.0,
                  top: 12.0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                    iconSize: 36,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Positioned(
                  right: 12.0,
                  top: 12.0,
                  child: IconButton(
                    icon: Builder(
                      builder: (context) {
                        if (flashLightState) {
                          return const Icon(Icons.flashlight_on_rounded, color: Colors.white);
                        }
                        return const Icon(Icons.flashlight_off_rounded, color: Colors.white);
                      },
                    ),
                    iconSize: 36.0,
                    onPressed: () async {
                      if (await scannerController.hasFlashlight()) {
                        setState(() {
                          scannerController.setFlashlightState(!flashLightState);
                          flashLightState = !flashLightState;
                        });
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  onDetected(BuildContext context, List<Barcode> barcodes) {
    if (barcodes[0].rawValue != null && lastBarcode != barcodes[0].rawValue) {
      lastBarcode = barcodes[0].rawValue!;
      const duration = Duration(seconds: 4);

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100, left: 40, right: 40),
        content: Text('${barcodes[0].format}\n${barcodes[0].type}\n\n$lastBarcode', textAlign: TextAlign.center),
      ));

      if (timerToClearLastBarcode != null) {
        timerToClearLastBarcode!.cancel();
      }
      timerToClearLastBarcode = Timer(duration, () {
        lastBarcode = '';
      });
    }
  }
}
