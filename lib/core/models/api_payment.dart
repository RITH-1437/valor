class PaymentTransactionModel {
  final int id;
  final int orderId;
  final String? orderNumber;
  final String provider;
  final String? transactionId;
  final double amount;
  final String currency;
  final String status;
  final String paymentMethod;
  final DateTime? paidAt;
  final DateTime? createdAt;

  PaymentTransactionModel({
    required this.id,
    required this.orderId,
    this.orderNumber,
    required this.provider,
    this.transactionId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    this.paidAt,
    this.createdAt,
  });

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) {
    return PaymentTransactionModel(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      orderNumber: json['order_number'],
      provider: json['provider'] ?? '',
      transactionId: json['transaction_id'],
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'] ?? '',
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}
