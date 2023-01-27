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

enum class LogLevel(val raw: Int) {
  NONE(0),
  CRITICAL(1),
  ERROR(2),
  WARNING(3),
  INFORMATIONAL(4),
  VERBOSE(5);

  companion object {
    fun ofRaw(raw: Int): LogLevel? {
      return values().firstOrNull { it.raw == raw }
    }
  }
}

/** Generated class from Pigeon that represents data sent in messages. */
data class LoggerError (
  val className: String? = null,
  val cause: String? = null,
  val message: String? = null,
  val stackTrace: String? = null,
  val isCritical: Boolean

) {
  companion object {
    @Suppress("UNCHECKED_CAST")
    fun fromList(list: List<Any?>): LoggerError {
      val className = list[0] as? String
      val cause = list[1] as? String
      val message = list[2] as? String
      val stackTrace = list[3] as? String
      val isCritical = list[4] as Boolean

      return LoggerError(className, cause, message, stackTrace, isCritical)
    }
  }
  fun toList(): List<Any?> {
    return listOf<Any?>(
      className,
      cause,
      message,
      stackTrace,
      isCritical,
    )
  }
}

/** Generated class from Pigeon that represents data sent in messages. */
data class LoggerMessage (
  val message: String,
  val logLevel: LogLevel

) {
  companion object {
    @Suppress("UNCHECKED_CAST")
    fun fromList(list: List<Any?>): LoggerMessage {
      val message = list[0] as String
      val logLevel = LogLevel.ofRaw(list[1] as Int)!!
      return LoggerMessage(message, logLevel)
    }
  }
  fun toList(): List<Any?> {
    return listOf<Any?>(
      message,
      logLevel?.raw,
    )
  }
}
@Suppress("UNCHECKED_CAST")
private object LoggerFlutterApiCodec : StandardMessageCodec() {
  override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any? {
    return when (type) {
      128.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          LoggerError.fromList(it)
        }
      }
      129.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          LoggerMessage.fromList(it)
        }
      }
      else -> super.readValueOfType(type, buffer)
    }
  }
  override fun writeValue(stream: ByteArrayOutputStream, value: Any?)   {
    when (value) {
      is LoggerError -> {
        stream.write(128)
        writeValue(stream, value.toList())
      }
      is LoggerMessage -> {
        stream.write(129)
        writeValue(stream, value.toList())
      }
      else -> super.writeValue(stream, value)
    }
  }
}

/** Generated class from Pigeon that represents Flutter messages that can be called from Kotlin. */
@Suppress("UNCHECKED_CAST")
class LoggerFlutterApi(private val binaryMessenger: BinaryMessenger) {
  companion object {
    /** The codec used by LoggerFlutterApi. */
    val codec: MessageCodec<Any?> by lazy {
      LoggerFlutterApiCodec
    }
  }
  fun logError(errorArg: LoggerError, callback: () -> Unit) {
    val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.LoggerFlutterApi.logError", codec)
    channel.send(listOf(errorArg)) {
      callback()
    }
  }
  fun logMessage(messageArg: LoggerMessage, callback: () -> Unit) {
    val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.LoggerFlutterApi.logMessage", codec)
    channel.send(listOf(messageArg)) {
      callback()
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
