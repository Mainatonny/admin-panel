// lib/models/payment.dart
class Payment {
  final String id;
  final String userId;
  final double amount;
  final DateTime date;
  final String status;

  Payment({
    required this.id,
    required this.userId,
    required this.amount,
    required this.date,
    required this.status,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? '',
    );
  }
}
