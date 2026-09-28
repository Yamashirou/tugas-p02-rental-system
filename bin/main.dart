import 'dart:convert';
import 'package:rental_system/exceptions.dart';
import 'package:rental_system/models.dart';

void main() async {
  print('=== 1. PEMBUATAN OBJEK DOMAIN ===');
  final car = Car(
    id: 'V-01',
    brand: 'Toyota GR Yaris',
    rentalRatePerDay: 850000.0,
    seatingCapacity: 4,
  );

  final customer = Customer(
    id: 'C-01',
    name: 'Andi Pratama',
    phoneNumber: '081234567890',
  );

  final order = RentalOrder(
    orderId: 'TRX-101',
    customer: customer,
    vehicle: car,
    durationDays: 3,
  );

  print('Order ID       : ${order.orderId}');
  print('Customer       : ${order.customer.name}');
  print('Kendaraan      : ${order.vehicle.brand}');
  print(
    'Total Tagihan  : Rp ${order.calculateTotalPrice().toStringAsFixed(0)}',
  );
  print('Status Awal    : ${order.status.name}\n');

  print('=== 2. SERIALISASI JSON & DESERIALISASI ===');
  final orderMap = order.toJson();
  final jsonString = jsonEncode(orderMap);
  print('Hasil toJson() : $jsonString');

  final restoredCustomer = Customer.fromJson(orderMap['customer']);
  print('Restored User  : ${restoredCustomer.name}\n');

  print('=== 3. EKSEKUSI METHOD ASYNC & COPYWITH ===');
  final finishedOrder = await order.completeRentalAsync(
    notes: 'Mobil kembali dalam kondisi bersih dan bensin penuh.',
  );
  print('Status Akhir   : ${finishedOrder.status.name}');
  print('Catatan        : ${finishedOrder.returnNotes}\n');

  print('=== 4. SIMULASI PELANGGARAN ATURAN (CUSTOM EXCEPTION) ===');
  try {
    print('Mencoba membuat order dengan durasi 0 hari...');
    RentalOrder(
      orderId: 'TRX-999',
      customer: customer,
      vehicle: car,
      durationDays: 0,
    );
  } on RentalException catch (e) {
    print('Tertangkap Exception: $e\n');
  }

  try {
    print('Mencoba menyelesaikan ulang order yang sudah selesai...');
    await finishedOrder.completeRentalAsync(notes: 'Coba kedua kali');
  } on RentalException catch (e) {
    print('Tertangkap Exception: $e');
  }
}
