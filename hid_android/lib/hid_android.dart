import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:hid_platform_interface/hid_platform_interface.dart';
import 'package:flutter/services.dart';

const MethodChannel _channel = MethodChannel('hid_android');

class HidAndroid extends HidPlatform {
  static void registerWith() {
    HidPlatform.instance = HidAndroid();
  }

  @override
  Future<List<Device>> getDeviceList() async {
    final List<Device> list = [];
    final List<Object?> devices = await _channel.invokeMethod('getDeviceList');
    for (var deviceObject in devices) {
      final rawDevice = deviceObject! as String;
      final device = jsonDecode(rawDevice);
      list.add(UsbDevice(
          vendorId: device['vendorId'],
          productId: device['productId'],
          serialNumber: device['serialNumber'],
          productName: device['productName'],
          deviceName: device['deviceName']));
    }
    return list;
  }
}

class UsbDevice extends Device {
  bool isOpen = false;
  String deviceName;
  UsbDevice(
      {required int vendorId,
      required int productId,
      required String serialNumber,
      required String productName,
      required this.deviceName})
      : super(
            vendorId: vendorId,
            productId: productId,
            serialNumber: serialNumber,
            productName: productName);

  @override
  Future<bool> open() async {
    final result = await _channel.invokeMethod('open', <String, String>{
      'deviceName': deviceName,
    });
    isOpen = result;
    return result;
  }

  @override
  Stream<List<int>> read(int length, int duration) async* {
    while (isOpen) {
      final start = DateTime.now();
      final List<Object?> array = await _channel.invokeMethod('read');
      yield array.map((e) => e! as int).toList();
      var t = DateTime.now().difference(start).inMilliseconds;
      t = min(max(0, t), duration);
      await Future.delayed(Duration(milliseconds: t));
    }
  }

  @override
  Future<void> close() async {
    isOpen = false;
    await _channel.invokeMethod('close');
  }
}
