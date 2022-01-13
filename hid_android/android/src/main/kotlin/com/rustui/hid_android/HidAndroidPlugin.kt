package com.rustui.hid_android

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.hardware.usb.UsbConstants
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbDeviceConnection
import android.hardware.usb.UsbManager
import android.util.Log
import androidx.annotation.NonNull
import com.google.gson.Gson

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** HidAndroidPlugin */
class HidAndroidPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel

    private lateinit var context: Context
    private lateinit var usbManager: UsbManager
    private val gson = Gson()
    private var connection: UsbDeviceConnection? = null
    private var device: UsbDevice? = null
    private var interfaceIndex: Int? = null
    private var endpointIndex: Int? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "hid_android")
        channel.setMethodCallHandler(this)

        context = flutterPluginBinding.applicationContext
        usbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getDeviceList" -> {
                val devices: MutableList<String> = mutableListOf()
                for (device in usbManager.deviceList.values) {
                    try {
                        val json = gson.toJson(
                            HidDevice(
                                device.vendorId,
                                device.productId,
                                device.serialNumber ?: "",
                                device.productName ?: "",
                                device.deviceName
                            )
                        )
                        devices.add(json)
                    } catch (e: Exception) {
                        val permissionIntent =
                            PendingIntent.getBroadcast(
                                context,
                                0,
                                Intent("ACTION_USB_PERMISSION"),
                                0
                            )
                        usbManager.requestPermission(device, permissionIntent)
                    }
                }
                result.success(devices)
            }
            "open" -> {
                device = usbManager.deviceList[call.argument("deviceName")]!!
                connection = usbManager.openDevice(device)
                (interfaceIndex, endpointIndex) = getReadIndices(device!!)!!
                result.success(
                    connection!!.claimInterface(
                        device!!.getInterface(interfaceIndex!!),
                        true
                    )
                )
            }
            "read" -> {
                if (connection != null) {
                    val length: Int = call.argument("length")!!
                    val duration: Int = call.argument("duration")!!
                    Thread {
                        kotlin.run {
                            val array = ByteArray(length)
                            connection!!.bulkTransfer(
                                device!!.getInterface(i).getEndpoint(j),
                                array,
                                length,
                                duration
                            )
                            result.success(array.map { it.toUByte().toInt() })
                        }
                    }.start()
                } else {
                    result.error("error", "error", "error")
                }
            }
            "close" -> {
                connection?.close()
                connection = null
                device = null
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

fun getReadIndices(device: UsbDevice): Pair<Int, Int>? {
    for (i in 0 until device.interfaceCount) {
        val inter = device.getInterface(i)
        for (j in 0 until inter.endpointCount) {
            val endpoint = inter.getEndpoint(j)
            if (endpoint.type == UsbConstants.USB_ENDPOINT_XFER_INT && endpoint.direction == UsbConstants.USB_DIR_IN) {
                return Pair(i, j)
            }
        }
    }
    return null
}