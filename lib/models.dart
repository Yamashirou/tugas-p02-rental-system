import 'exceptions.dart';

enum RentalStatus { active, completed, cancelled }

const Object _undefined = Object();

abstract class Vehicle {
  final String id;
  final String brand;
  final double rentalRatePerDay;

  Vehicle({
    required this.id,
    required this.brand,
    required this.rentalRatePerDay,
  }) {
    if (rentalRatePerDay <= 0) {
      throw RentalException('Harga sewa per hari harus lebih dari 0.');
    }
  }

  Map<String, dynamic> toJson();
}

class Car extends Vehicle {
  final int seatingCapacity;

  Car({
    required super.id,
    required super.brand,
    required super.rentalRatePerDay,
    required this.seatingCapacity,
  }) {
    if (seatingCapacity <= 0) {
      throw RentalException('Kapasitas tempat duduk harus lebih dari 0.');
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'rentalRatePerDay': rentalRatePerDay,
      'seatingCapacity': seatingCapacity,
    };
  }
}

class Customer {
  final String id;
  final String name;
  final String? phoneNumber;

  Customer({
    required this.id,
    required this.name,
    this.phoneNumber,
  }) {
    if (name.trim().isEmpty) {
      throw RentalException('Nama pelanggan tidak boleh kosong.');
    }
  }

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

class RentalOrder {
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
    Object? returnNotes = _undefined,
  }) {
    return RentalOrder(
      orderId: orderId ?? this.orderId,
      customer: customer ?? this.customer,
      vehicle: vehicle ?? this.vehicle,
      durationDays: durationDays ?? this.durationDays,
      status: status ?? this.status,
      returnNotes: identical(returnNotes, _undefined)
          ? this.returnNotes
          : returnNotes as String?,
    );
  }

  RentalOrder cancel({String? reason}) {
    if (status == RentalStatus.completed) {
      throw RentalException(
        'Order $orderId yang sudah selesai tidak dapat dibatalkan.',
      );
    }
    if (status == RentalStatus.cancelled) {
      throw RentalException('Order $orderId sudah pernah dibatalkan.');
    }

    return copyWith(
      status: RentalStatus.cancelled,
      returnNotes: reason,
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
    if (status == RentalStatus.cancelled) {
      throw RentalException(
        'Order $orderId yang sudah dibatalkan tidak dapat diselesaikan.',
      );
    }
    if (status == RentalStatus.completed) {
      throw RentalException('Order $orderId sudah pernah diselesaikan.');
    }

    await Future.delayed(const Duration(milliseconds: 600));

    final updated = copyWith(
      status: RentalStatus.completed,
      returnNotes: notes,
    );

    return updated;
  }
}
