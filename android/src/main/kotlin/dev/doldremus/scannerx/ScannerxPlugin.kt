package dev.doldremus.scannerx

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** ScannerxPlugin */
class ScannerxPlugin: FlutterPlugin, ActivityAware {
  private var flutterBinding: FlutterPlugin.FlutterPluginBinding? = null
  private var activityBinding: ActivityPluginBinding? = null
  private var scannerHostApi: ScannerHostApiImpl? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    flutterBinding = flutterPluginBinding
    scannerHostApi = ScannerHostApiImpl()
    ScannerHostApi.setUp(flutterPluginBinding.binaryMessenger, scannerHostApi)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    flutterBinding = null
    ScannerHostApi.setUp(binding.binaryMessenger, null)
    scannerHostApi = null
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activityBinding = binding
    if (flutterBinding != null) {
      scannerHostApi?.onActivityInit(flutterBinding!!, binding)
    }
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {
    scannerHostApi?.onActivityDispose()
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }
}
