import 'dart:ffi';
import 'dart:typed_data';

import 'package:hid_platform_interface/hid_platform_interface.dart';
import 'package:ffi/ffi.dart';
import 'generated_bindings.dart';

final _api = Api(DynamicLibrary.executable());

class HidPluginMacOS extends HidPlatform {
  static void registerWith() {
    HidPlatform.instance = HidPluginMacOS();
  }

  @override
  Future<List<Device>> getDeviceList() async {
    List<Device> devices = [];
    final pointer = _api.enumerate(0, 0);
    var current = pointer;
    while (current.address != nullptr.address) {
      final ref = current.ref;
      devices.add(UsbDevice(
        vendorId: ref.vendor_id,
        productId: ref.product_id,
        serialNumber: ref.serial_number.toDartString(),
        productName: ref.product_string.toDartString(),
        usagePage: ref.usage_page,
        usage: ref.usage,
      ));
      current = ref.next;
    }
    _api.free_enumeration(pointer);
    return devices;
  }
}

class UsbDevice extends Device {
  Pointer<hid_device>? _raw;
  bool isOpen = false;

  UsbDevice({
    required int vendorId,
    required int productId,
    required String serialNumber,
    required String productName,
    required int usagePage,
    required int usage,
  }) : super(
            vendorId: vendorId,
            productId: productId,
            serialNumber: serialNumber,
            productName: productName);

  @override
  Future<bool> open() async {
    final pointer = _api.open(vendorId, productId, serialNumber.toPointer());
    if (pointer.address == nullptr.address) return false;
    final result = _api.set_nonblocking(pointer, 1);
    if (result == -1) return false;
    _raw = pointer;
    isOpen = true;
    return true;
  }

  @override
  Future<void> close() async {
    isOpen = false;
    final raw = _raw;
    if (raw != null) {
      _api.close(raw);
    }
  }

  @override
  Stream<Uint8List> read(int length, int duration) async* {
    final raw = _raw;
    if (raw == null) throw Exception();
    final buf = calloc<Uint8>(length);
    var count = 0;
    while (isOpen) {
      count = _api.read(raw, buf, length);
      if (count == -1) {
        break;
      } else if (count > 0) {
        yield buf.asTypedList(count);
      }
      await Future.delayed(Duration(milliseconds: duration));
    }
    calloc.free(buf);
  }

  @override
  Future<void> write(Uint8List bytes) async {
    final raw = _raw;
    if (raw == null) throw Exception();
    final buf = calloc<Uint8>(bytes.lengthInBytes);
    final Uint8List _buf = buf.asTypedList(bytes.lengthInBytes);
    _buf.setRange(0, bytes.lengthInBytes, bytes);
    var offset = 0;
    while (isOpen && bytes.lengthInBytes - offset > 0) {
      final count =
          _api.write(raw, buf.elementAt(offset), bytes.lengthInBytes - offset);
      if (count == -1) {
        break;
      } else {
        offset += count;
      }
    }
    calloc.free(buf);
  }
}

extension PointerToString on Pointer<Int32> {
  String toDartString() {
    final buffer = StringBuffer();
    var i = 0;
    while (true) {
      final char = elementAt(i).value;
      if (char == 0) {
        return buffer.toString();
      }
      buffer.writeCharCode(char);
      i++;
    }
  }
}

extension StringToPointer on String {
  Pointer<Int32> toPointer({Allocator allocator = malloc}) {
    final units = codeUnits;
    final Pointer<Int32> result = allocator<Int32>(units.length + 1);
    final Int32List nativeString = result.asTypedList(units.length + 1);
    nativeString.setRange(0, units.length, units);
    nativeString[units.length] = 0;
    return result.cast();
  }
}
