package com.rustui.hid_android

class HidDevice(
    val vendorId: Int,
    val productId: Int,
    val serialNumber: String,
    val productName: String,
    val deviceName: String
) {
}