import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'device.dart';
export 'device.dart';

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
