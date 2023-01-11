// Copyright 2022 Doldremus. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v5.0.0), do not edit directly.
// See also: https://pub.dev/packages/pigeon

package dev.doldremus.scannerx

import android.util.Log
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.common.StandardMessageCodec
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer

/** Generated class from Pigeon. */

enum class CameraLensDirection(val raw: Int) {
  FRONT(0),
  BACK(1);

  companion object {
    fun ofRaw(raw: Int): CameraLensDirection? {
      return values().firstOrNull { it.raw == raw }
    }
  }
}

/** Generated class from Pigeon that represents data sent in messages. */
data class ScannerOptions (
  val targetResolution: Resolution? = null,
  val lensDirection: CameraLensDirection? = null

) {
  companion object {
    @Suppress("UNCHECKED_CAST")
    fun fromList(list: List<Any?>): ScannerOptions {
      val targetResolution: Resolution? = (list[0] as? List<Any?>)?.let {
        Resolution.fromList(it)
      }
      val lensDirection: CameraLensDirection? = (list[1] as? Int)?.let {
        CameraLensDirection.ofRaw(it)
      }

      return ScannerOptions(targetResolution, lensDirection)
    }
  }
  fun toList(): List<Any?> {
    return listOf<Any?>(
      targetResolution?.toList(),
      lensDirection?.raw,
    )
  }
}

/** Generated class from Pigeon that represents data sent in messages. */
data class RawScannerDescription (
  val texture: RawTextureDescription,
  val analysis: RawAnalysisDescription

) {
  companion object {
    @Suppress("UNCHECKED_CAST")
    fun fromList(list: List<Any?>): RawScannerDescription {
      val texture = RawTextureDescription.fromList(list[0] as List<Any?>)
      val analysis = RawAnalysisDescription.fromList(list[1] as List<Any?>)

      return RawScannerDescription(texture, analysis)
    }
  }
  fun toList(): List<Any?> {
    return listOf<Any?>(
      texture?.toList(),
      analysis?.toList(),
    )
  }
}

/** Generated class from Pigeon that represents data sent in messages. */
data class RawTextureDescription (
  val id: Long,
  val resolution: Resolution

) {
  companion object {
    @Suppress("UNCHECKED_CAST")
    fun fromList(list: List<Any?>): RawTextureDescription {
      val id = list[0] as Long
      val resolution = Resolution.fromList(list[1] as List<Any?>)

      return RawTextureDescription(id, resolution)
    }
  }
  fun toList(): List<Any?> {
    return listOf<Any?>(
      id,
      resolution?.toList(),
    )
  }
}

/** Generated class from Pigeon that represents data sent in messages. */
data class RawAnalysisDescription (
  val resolution: Resolution

) {
  companion object {
    @Suppress("UNCHECKED_CAST")
    fun fromList(list: List<Any?>): RawAnalysisDescription {
      val resolution = Resolution.fromList(list[0] as List<Any?>)

      return RawAnalysisDescription(resolution)
    }
  }
  fun toList(): List<Any?> {
    return listOf<Any?>(
      resolution?.toList(),
    )
  }
}

/** Generated class from Pigeon that represents data sent in messages. */
data class Resolution (
  val width: Double,
  val height: Double

) {
  companion object {
    @Suppress("UNCHECKED_CAST")
    fun fromList(list: List<Any?>): Resolution {
      val width = list[0] as Double
      val height = list[1] as Double

      return Resolution(width, height)
    }
  }
  fun toList(): List<Any?> {
    return listOf<Any?>(
      width,
      height,
    )
  }
}

/** Generated class from Pigeon that represents data sent in messages. */
data class PermissionsResponse (
  val granted: Boolean,
  val permanentlyDenied: Boolean

) {
  companion object {
    @Suppress("UNCHECKED_CAST")
    fun fromList(list: List<Any?>): PermissionsResponse {
      val granted = list[0] as Boolean
      val permanentlyDenied = list[1] as Boolean

      return PermissionsResponse(granted, permanentlyDenied)
    }
  }
  fun toList(): List<Any?> {
    return listOf<Any?>(
      granted,
      permanentlyDenied,
    )
  }
}

@Suppress("UNCHECKED_CAST")
private object ScannerHostApiCodec : StandardMessageCodec() {
  override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any? {
    return when (type) {
      128.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          PermissionsResponse.fromList(it)
        }
      }
      129.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          RawAnalysisDescription.fromList(it)
        }
      }
      130.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          RawScannerDescription.fromList(it)
        }
      }
      131.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          RawTextureDescription.fromList(it)
        }
      }
      132.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          Resolution.fromList(it)
        }
      }
      133.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          Resolution.fromList(it)
        }
      }
      134.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          ScannerOptions.fromList(it)
        }
      }
      else -> super.readValueOfType(type, buffer)
    }
  }
  override fun writeValue(stream: ByteArrayOutputStream, value: Any?)   {
    when (value) {
      is PermissionsResponse -> {
        stream.write(128)
        writeValue(stream, value.toList())
      }
      is RawAnalysisDescription -> {
        stream.write(129)
        writeValue(stream, value.toList())
      }
      is RawScannerDescription -> {
        stream.write(130)
        writeValue(stream, value.toList())
      }
      is RawTextureDescription -> {
        stream.write(131)
        writeValue(stream, value.toList())
      }
      is Resolution -> {
        stream.write(132)
        writeValue(stream, value.toList())
      }
      is Resolution -> {
        stream.write(133)
        writeValue(stream, value.toList())
      }
      is ScannerOptions -> {
        stream.write(134)
        writeValue(stream, value.toList())
      }
      else -> super.writeValue(stream, value)
    }
  }
}

/** Generated interface from Pigeon that represents a handler of messages from Flutter. */
interface ScannerHostApi {
  fun requestPermissions(callback: (PermissionsResponse) -> Unit)
  fun init(options: ScannerOptions, callback: (RawScannerDescription?) -> Unit)
  fun dispose(callback: () -> Unit)
  fun hasFlashlight(): Boolean
  fun getFlashlightState(): Boolean
  fun setFlashlightState(state: Boolean)

  companion object {
    /** The codec used by ScannerHostApi. */
    val codec: MessageCodec<Any?> by lazy {
      ScannerHostApiCodec
    }
    /** Sets up an instance of `ScannerHostApi` to handle messages through the `binaryMessenger`. */
    @Suppress("UNCHECKED_CAST")
    fun setUp(binaryMessenger: BinaryMessenger, api: ScannerHostApi?) {
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.ScannerHostApi.requestPermissions", codec)
        if (api != null) {
          channel.setMessageHandler { _, reply ->
            var wrapped = listOf<Any?>()
            try {
              api.requestPermissions() {
                reply.reply(wrapResult(it))
              }
            } catch (exception: Error) {
              wrapped = wrapError(exception)
              reply.reply(wrapped)
            }
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.ScannerHostApi.init", codec)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            var wrapped = listOf<Any?>()
            try {
              val args = message as List<Any?>
              val optionsArg = args[0] as ScannerOptions
              api.init(optionsArg) {
                reply.reply(wrapResult(it))
              }
            } catch (exception: Error) {
              wrapped = wrapError(exception)
              reply.reply(wrapped)
            }
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.ScannerHostApi.dispose", codec)
        if (api != null) {
          channel.setMessageHandler { _, reply ->
            var wrapped = listOf<Any?>()
            try {
              api.dispose() {
                reply.reply(wrapResult(null))
              }
            } catch (exception: Error) {
              wrapped = wrapError(exception)
              reply.reply(wrapped)
            }
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.ScannerHostApi.hasFlashlight", codec)
        if (api != null) {
          channel.setMessageHandler { _, reply ->
            var wrapped = listOf<Any?>()
            try {
              wrapped = listOf<Any?>(api.hasFlashlight())
            } catch (exception: Error) {
              wrapped = wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.ScannerHostApi.getFlashlightState", codec)
        if (api != null) {
          channel.setMessageHandler { _, reply ->
            var wrapped = listOf<Any?>()
            try {
              wrapped = listOf<Any?>(api.getFlashlightState())
            } catch (exception: Error) {
              wrapped = wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.ScannerHostApi.setFlashlightState", codec)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            var wrapped = listOf<Any?>()
            try {
              val args = message as List<Any?>
              val stateArg = args[0] as Boolean
              api.setFlashlightState(stateArg)
              wrapped = listOf<Any?>(null)
            } catch (exception: Error) {
              wrapped = wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
    }
  }
}

private fun wrapResult(result: Any?): List<Any?> {
  return listOf(result)
}

private fun wrapError(exception: Throwable): List<Any> {
  return listOf<Any>(
    exception.javaClass.simpleName,
    exception.toString(),
    "Cause: " + exception.cause + ", Stacktrace: " + Log.getStackTraceString(exception)
  )
}
