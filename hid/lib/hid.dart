import 'package:hid_platform_interface/hid_platform_interface.dart';

export 'package:hid_platform_interface/device.dart';

HidPlatform get _platform => HidPlatform.instance;
Future<List<Device>> getDeviceList() {
  return _platform.getDeviceList();
}
