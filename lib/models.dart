import 'exceptions.dart';
import 'mixins.dart';

enum RentalStatus { active, completed, cancelled }

abstract class Vehicle {
  final String id;
  final String brand;
  final double rentalRatePerDay;

  Vehicle({
    required this.id,
    required this.brand,
    required this.rentalRatePerDay,
  });

  Map<String, dynamic> toJson();
}

class Car extends Vehicle {
  final int seatingCapacity;

  Car({
    required super.id,
    required super.brand,
    required super.rentalRatePerDay,
    required this.seatingCapacity,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'rentalRatePerDay': rentalRatePerDay,
      'seatingCapacity': seatingCapacity,
    };
  }

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] as String,
      brand: json['brand'] as String,
      rentalRatePerDay: (json['rentalRatePerDay'] as num).toDouble(),
      seatingCapacity: json['seatingCapacity'] as int,
    );
  }
}

class Customer {
  final String id;
  final String name;
  final String? phoneNumber;

  Customer({required this.id, required this.name, this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }
}

class RentalOrder with Loggable {
  final String orderId;
  final Customer customer;
  final Vehicle vehicle;
  final int durationDays;
  final RentalStatus status;
  final String? returnNotes;

  RentalOrder({
    required this.orderId,
    required this.customer,
    required this.vehicle,
    required this.durationDays,
    this.status = RentalStatus.active,
    this.returnNotes,
  }) {
    if (durationDays <= 0) {
      throw RentalException('Durasi rental minimal harus 1 hari.');
    }
  }

  double calculateTotalPrice() {
    return vehicle.rentalRatePerDay * durationDays;
  }

  RentalOrder copyWith({
    String? orderId,
    Customer? customer,
    Vehicle? vehicle,
    int? durationDays,
    RentalStatus? status,
    String? returnNotes,
  }) {
    return RentalOrder(
      orderId: orderId ?? this.orderId,
      customer: customer ?? this.customer,
      vehicle: vehicle ?? this.vehicle,
      durationDays: durationDays ?? this.durationDays,
      status: status ?? this.status,
      returnNotes: returnNotes ?? this.returnNotes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'customer': customer.toJson(),
      'vehicle': vehicle.toJson(),
      'durationDays': durationDays,
      'status': status.name,
      if (returnNotes != null) 'returnNotes': returnNotes,
    };
  }

  Future<RentalOrder> completeRentalAsync({String? notes}) async {
    logAction('Memulai pemrosesan pengembalian kendaraan order: $orderId');
    try {
      if (status == RentalStatus.completed) {
        throw RentalException('Order $orderId sudah pernah diselesaikan.');
      }

      await Future.delayed(const Duration(milliseconds: 600));

      final updated = copyWith(
        status: RentalStatus.completed,
        returnNotes: notes,
      );

      logAction('Order $orderId berhasil ditutup.');
      return updated;
    } catch (e) {
      logAction('Gagal memproses pengembalian order $orderId: $e');
      rethrow;
    }
  }
}
