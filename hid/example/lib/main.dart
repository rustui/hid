import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hid/hid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Device>? _hidDevices;

  @override
  void initState() {
    super.initState();
    _listDevices();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _listDevices() async {
    setState(() {
      _hidDevices = null;
    });

    final hidDevices = await getDeviceList();
    hidDevices.sort((a, b) => a.usage?.compareTo(b.usage ?? 0) ?? 0);
    hidDevices.sort((a, b) => a.usagePage?.compareTo(b.usagePage ?? 0) ?? 0);
    hidDevices.sort((a, b) => a.productId.compareTo(b.productId));
    hidDevices.sort((a, b) => a.vendorId.compareTo(b.vendorId));
    hidDevices.sort((a, b) => a.productName.compareTo(b.productName));

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _hidDevices = hidDevices;
    });
  }

  _getUsagePageIcon(int? usagePage, int? usage) {
    switch (usagePage) {
      case 0x01:
        switch (usage) {
          case 0x01:
            return Icons.north_west;
          case 0x02:
            return Icons.mouse;
          case 0x04:
          case 0x05:
            return Icons.gamepad;
          case 0x06:
            return Icons.keyboard;
        }
        return Icons.computer;
      case 0x0b:
        switch (usage) {
          case 0x04:
          case 0x05:
            return Icons.headset_mic;
        }
        return Icons.phone;
      case 0x0c:
        return Icons.toggle_on;
      case 0x0d:
        return Icons.touch_app;
      case 0xf1d0:
        return Icons.security;
    }
    return Icons.usb;
  }

  @override
  Widget build(BuildContext context) {
    final dev = _hidDevices;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('HID Plugin example app'),
        ),
        body: dev == null
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: dev.length,
                itemBuilder: (context, index) => ListTile(
                  leading: Icon(_getUsagePageIcon(
                      dev[index].usagePage, dev[index].usage)),
                  title: Text(dev[index].productName),
                  subtitle: Text(
                      '${dev[index].vendorId.toRadixString(16).padLeft(4, '0')}:${dev[index].productId.toRadixString(16).padLeft(4, '0')}   ${dev[index].serialNumber}'),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.refresh),
          onPressed: dev == null ? null : _listDevices,
        ),
      ),
    );
  }
}
