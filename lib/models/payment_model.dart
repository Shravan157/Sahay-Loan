class PaymentModel {
  final String? paymentId;
  final String loanId;
  final int month;
  final double amount;
  final String status; // success, failed, pending
  final DateTime? paidAt;
  final String? paymentMethod;
  final String? transactionId;

  PaymentModel({
    this.paymentId,
    required this.loanId,
    required this.month,
    required this.amount,
    required this.status,
    this.paidAt,
    this.paymentMethod,
    this.transactionId,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      paymentId: json['payment_id'],
      loanId: json['loan_id'] ?? '',
      month: json['month'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'])
          : null,
      paymentMethod: json['payment_method'],
      transactionId: json['transaction_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'loan_id': loanId,
      'month': month,
      'amount': amount,
      'status': status,
      'paid_at': paidAt?.toIso8601String(),
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
    };
  }

  bool get isSuccess => status == 'success';
  bool get isFailed => status == 'failed';
  bool get isPending => status == 'pending';
}
