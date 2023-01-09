import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scannerx/scannerx.dart';

typedef ScannerChildBuilder = Widget Function(ScannerDescription description);

class Scanner extends StatelessWidget {
  const Scanner({required this.controller, this.childBuilder, this.loader, Key? key}) : super(key: key);

  final ScannerController controller;
  final ScannerChildBuilder? childBuilder;
  final Widget? loader;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.initialized,
      builder: (context, value, child) => _build(context, value),
    );
  }

  Widget _build(BuildContext context, bool initialized) {
    if (initialized) {
      return Stack(
        children: [
          ClipRect(
            child: Transform.scale(
              scale: controller.description!.texture.fitScale,
              child: Center(
                child: AspectRatio(
                  aspectRatio: controller.description!.texture.aspectRatio,
                  child: Texture(textureId: controller.description!.texture.id, filterQuality: FilterQuality.none),
                ),
              ),
            ),
          ),
          if (childBuilder != null) childBuilder!(controller.description!),
        ],
      );
    }
    return Container(
      color: Colors.black,
      child: loader,
    );
  }
}

abstract class ScannerController {
  factory ScannerController({
    Function(LoggerError error)? onPlatformError,
    LogLevel? logLevel,
  }) =>
      _ScannerController(
        onPlatformError: onPlatformError,
        logLevel: logLevel,
      );

  Stream<List<Barcode>> get barcodes;

  ScannerDescription? get description;

  ValueNotifier<bool> get initialized;

  Future<void> init({ScannerOptions? options});

  Future<void> dispose();

  Future<bool> hasFlashlight();

  Future<bool> getFlashlightState();

  Future<void> setFlashlightState(bool state);
}

class _ScannerController implements ScannerController {
  _ScannerController({Function(LoggerError error)? onPlatformError, LogLevel? logLevel}) {
    _scannerHostApi = ScannerHostApi();

    _barcodeFlutterApi = _BarcodeFlutterApiImpl(this);
    BarcodeFlutterApi.setup(_barcodeFlutterApi);

    _loggerFlutterApi = _LoggerFlutterApiImpl(onPlatformError, logLevel ?? LogLevel.verbose);
    LoggerFlutterApi.setup(_loggerFlutterApi);
  }

  late ScannerHostApi _scannerHostApi;
  late _BarcodeFlutterApiImpl _barcodeFlutterApi;
  late _LoggerFlutterApiImpl _loggerFlutterApi;

  @override
  ScannerDescription? description;

  @override
  ValueNotifier<bool> initialized = ValueNotifier(false);

  @override
  Stream<List<Barcode>> get barcodes => _barcodeFlutterApi.barcodesStreamController.stream;

  @override
  Future<void> init({ScannerOptions? options}) async {
    initialized.value = false;
    final rawScannerDescription = await _scannerHostApi.init(options ?? ScannerOptions());
    if (rawScannerDescription != null) {
      description = ScannerDescription.fromRaw(rawScannerDescription);
    }
    initialized.value = true;
  }

  @override
  Future<void> dispose() async {
    initialized.value = false;
    await _barcodeFlutterApi.dispose();
    await _scannerHostApi.dispose();
    BarcodeFlutterApi.setup(null);
  }

  @override
  Future<bool> hasFlashlight() {
    return _scannerHostApi.hasFlashlight();
  }

  @override
  Future<bool> getFlashlightState() {
    return _scannerHostApi.getFlashlightState();
  }

  @override
  Future<void> setFlashlightState(bool state) {
    return _scannerHostApi.setFlashlightState(state);
  }
}

class _BarcodeFlutterApiImpl implements BarcodeFlutterApi {
  _BarcodeFlutterApiImpl(this.controller) {
    barcodesStreamController = StreamController.broadcast();
  }

  final _ScannerController controller;
  late StreamController<List<Barcode>> barcodesStreamController;
  bool emptyAlreadyBroadcast = false;

  @override
  void barcodes(List<RawBarcode?>? barcodes) {
    if (barcodes?.isNotEmpty == true) {
      final safeList = barcodes!.where((e) => e != null).toList();
      final list = safeList.map((e) => Barcode.fromRaw(controller.description, e!)).toList();
      if (list.isNotEmpty) {
        broadcast(list);
      } else {
        broadcastEmpty();
      }
    } else {
      broadcastEmpty();
    }
  }

  broadcast(List<Barcode> barcodes) {
    if (barcodesStreamController.isClosed) return;

    barcodesStreamController.add(barcodes);
    emptyAlreadyBroadcast = false;
  }

  broadcastEmpty() {
    if (barcodesStreamController.isClosed) return;

    if (!emptyAlreadyBroadcast) {
      barcodesStreamController.add([]);
      emptyAlreadyBroadcast = true;
    }
  }

  Future<void> dispose() async {
    await barcodesStreamController.close();
  }
}

class _LoggerFlutterApiImpl implements LoggerFlutterApi {
  _LoggerFlutterApiImpl(this.handler, this.logLevel);

  final void Function(LoggerError error)? handler;
  final LogLevel logLevel;

  @override
  void logError(LoggerError error) {
    if (error.isCritical ? (LogLevel.critical.index <= logLevel.index) : (LogLevel.error.index <= logLevel.index)) {
      debugPrint('Scanner ${error.className} \n ${error.cause} \n ${error.description} \n ${error.stackTrace}');
    }
    if (handler != null) handler!(error);
  }

  @override
  void logMessage(LoggerMessage message) {
    if (message.logLevel.index <= logLevel.index) {
      debugPrint(message.message);
    }
  }
}
