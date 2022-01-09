abstract class Device {
  int vendorId;
  int productId;
  String serialNumber;
  String productName;
  int usagePage;
  int usage;
  Device({
    required this.vendorId,
    required this.productId,
    required this.serialNumber,
    required this.productName,
    required this.usagePage,
    required this.usage,
  });

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