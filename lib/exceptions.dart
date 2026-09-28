class RentalException implements Exception {
  final String message;

  RentalException(this.message);

  @override
  String toString() => 'RentalException: $message';
}
