import 'dart:convert';
import 'package:rental_system/exceptions.dart';
import 'package:rental_system/models.dart';

void main() async {
  print('=== 1. PEMBUATAN OBJEK DOMAIN ===');
  final car = Car(
    id: 'V-01',
    brand: 'Toyota Avanza',
    rentalRatePerDay: 350000.0,
    seatingCapacity: 7,
  );

  final customer = Customer(
    id: 'C-01',
    name: 'Ragil Situmorang',
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
  print('Catatan        : ${finishedOrder.returnNotes}');

  final clearedNotesOrder = finishedOrder.copyWith(returnNotes: null);
  print(
    'Hapus Catatan  : ${clearedNotesOrder.returnNotes ?? "(null - catatan berhasil dikosongkan)"}\n',
  );

  print('=== 4. MANAJEMEN STATUS CANCELLED ===');
  final cancelableOrder = RentalOrder(
    orderId: 'TRX-102',
    customer: customer,
    vehicle: car,
    durationDays: 1,
  );
  print('Status Order TRX-102 : ${cancelableOrder.status.name}');
  final cancelledOrder = cancelableOrder.cancel(
    reason: 'Pelanggan punya hutang yang belum lunas',
  );
  print('Status Setelah Cancel: ${cancelledOrder.status.name}');
  print('Catatan Pembatalan   : ${cancelledOrder.returnNotes}\n');

  print('=== 5. SIMULASI PELANGGARAN ATURAN (CUSTOM EXCEPTION) ===');
  try {
    print('1. Mencoba order dengan durasi 0 hari...');
    RentalOrder(
      orderId: 'TRX-991',
      customer: customer,
      vehicle: car,
      durationDays: 0,
    );
  } on RentalException catch (e) {
    print('   Tertangkap Exception: $e');
  }

  try {
    print('2. Mencoba membuat kendaraan dengan tarif Rp 0...');
    Car(
      id: 'V-02',
      brand: 'Mobil Gratis',
      rentalRatePerDay: 0,
      seatingCapacity: 4,
    );
  } on RentalException catch (e) {
    print('   Tertangkap Exception: $e');
  }

  try {
    print('3. Mencoba membuat mobil dengan kapasitas 0 penumpang...');
    Car(
      id: 'V-03',
      brand: 'Mobil Hantu',
      rentalRatePerDay: 500000,
      seatingCapacity: 0,
    );
  } on RentalException catch (e) {
    print('   Tertangkap Exception: $e');
  }

  try {
    print('4. Mencoba membuat customer dengan nama kosong...');
    Customer(id: 'C-99', name: '   ', phoneNumber: '081234567890');
  } on RentalException catch (e) {
    print('   Tertangkap Exception: $e');
  }

  try {
    print('5. Mencoba menyelesaikan ulang order yang sudah selesai...');
    await finishedOrder.completeRentalAsync(notes: 'Coba kedua kali');
  } on RentalException catch (e) {
    print('   Tertangkap Exception: $e');
  }

  try {
    print('6. Mencoba menyelesaikan order yang berstatus cancelled...');
    await cancelledOrder.completeRentalAsync();
  } on RentalException catch (e) {
    print('   Tertangkap Exception: $e');
  }

  try {
    print('7. Mencoba membatalkan order yang sudah selesai...');
    finishedOrder.cancel(reason: 'Ingin dibatalkan setelah selesai');
  } on RentalException catch (e) {
    print('   Tertangkap Exception: $e');
  }
}
