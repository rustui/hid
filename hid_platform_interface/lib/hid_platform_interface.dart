import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class HidPlatform extends PlatformInterface {
  HidPlatform() : super(token: _token);

  static final Object _token = Object();

  static late HidPlatform _instance;

  static HidPlatform get instance => _instance;

  static set instance(HidPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List<Device>> getDeviceList() {
    throw UnimplementedError();
  }
}

abstract class Device {
  int vendorId;
  int productId;
  String serialNumber;
  String productName;
  Device(
      {required this.vendorId,
      required this.productId,
      required this.serialNumber,
      required this.productName});

  Future<bool> open() {
    throw UnimplementedError();
  }

  Future<void> close() {
    throw UnimplementedError();
  }

  Stream<List<int>> read() {
    throw UnimplementedError();
  }
}
