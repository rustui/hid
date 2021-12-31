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

  Stream<List<int>> read(int length, int duration) {
    throw UnimplementedError();
  }
}