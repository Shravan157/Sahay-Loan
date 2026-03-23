class LoanModel {
  final String loanId;
  final String uid;
  final double loanAmount;
  final int durationMonths;
  final String purpose;
  final double rateOfInterest;
  final double monthlyEmi;
  final double totalPayable;
  final double totalInterest;
  final String status;
  final bool disclaimerAccepted;
  final DateTime? appliedAt;
  final String? companyId;
  final String? userNotification;
  final DateTime? notifiedAt;

  LoanModel({
    required this.loanId,
    required this.uid,
    required this.loanAmount,
    required this.durationMonths,
    required this.purpose,
    required this.rateOfInterest,
    required this.monthlyEmi,
    required this.totalPayable,
    required this.totalInterest,
    required this.status,
    this.disclaimerAccepted = false,
    this.appliedAt,
    this.companyId,
    this.userNotification,
    this.notifiedAt,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      loanId: json['loan_id'] ?? '',
      uid: json['uid'] ?? '',
      loanAmount: (json['loan_amount'] ?? 0).toDouble(),
      durationMonths: json['duration_months'] ?? 0,
      purpose: json['purpose'] ?? '',
      rateOfInterest: (json['rate_of_interest'] ?? 0).toDouble(),
      monthlyEmi: (json['monthly_emi'] ?? 0).toDouble(),
      totalPayable: (json['total_payable'] ?? 0).toDouble(),
      totalInterest: (json['total_interest'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      disclaimerAccepted: json['disclaimer_accepted'] ?? false,
      appliedAt: json['applied_at'] != null
          ? DateTime.tryParse(json['applied_at'])
          : null,
      companyId: json['company_id'],
      userNotification: json['user_notification'],
      notifiedAt: json['notified_at'] != null
          ? DateTime.tryParse(json['notified_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loan_id': loanId,
      'uid': uid,
      'loan_amount': loanAmount,
      'duration_months': durationMonths,
      'purpose': purpose,
      'rate_of_interest': rateOfInterest,
      'monthly_emi': monthlyEmi,
      'total_payable': totalPayable,
      'total_interest': totalInterest,
      'status': status,
      'disclaimer_accepted': disclaimerAccepted,
      'applied_at': appliedAt?.toIso8601String(),
      'company_id': companyId,
      'user_notification': userNotification,
      'notified_at': notifiedAt?.toIso8601String(),
    };
  }

  LoanModel copyWith({
    String? loanId,
    String? uid,
    double? loanAmount,
    int? durationMonths,
    String? purpose,
    double? rateOfInterest,
    double? monthlyEmi,
    double? totalPayable,
    double? totalInterest,
    String? status,
    bool? disclaimerAccepted,
    DateTime? appliedAt,
    String? companyId,
    String? userNotification,
    DateTime? notifiedAt,
  }) {
    return LoanModel(
      loanId: loanId ?? this.loanId,
      uid: uid ?? this.uid,
      loanAmount: loanAmount ?? this.loanAmount,
      durationMonths: durationMonths ?? this.durationMonths,
      purpose: purpose ?? this.purpose,
      rateOfInterest: rateOfInterest ?? this.rateOfInterest,
      monthlyEmi: monthlyEmi ?? this.monthlyEmi,
      totalPayable: totalPayable ?? this.totalPayable,
      totalInterest: totalInterest ?? this.totalInterest,
      status: status ?? this.status,
      disclaimerAccepted: disclaimerAccepted ?? this.disclaimerAccepted,
      appliedAt: appliedAt ?? this.appliedAt,
      companyId: companyId ?? this.companyId,
      userNotification: userNotification ?? this.userNotification,
      notifiedAt: notifiedAt ?? this.notifiedAt,
    );
  }

  bool get isPending =>
      status == 'pending' || status == 'pending_sahay_review';
  bool get isUnderReview => status == 'under_review' || status == 'shared_with_provider';
  bool get isApproved =>
      status == 'approved' || status == 'provider_approved';
  bool get isDisbursed => status == 'disbursed';
  bool get isCompleted => status == 'completed';
  bool get isRejected => status == 'rejected' || status == 'provider_rejected';
}

class RepaymentModel {
  final String loanId;
  final String uid;
  final int month;
  final double amount;
  final String dueDate;
  final String status;
  final double penalty;
  final DateTime? paidAt;

  RepaymentModel({
    required this.loanId,
    required this.uid,
    required this.month,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.penalty = 0,
    this.paidAt,
  });

  factory RepaymentModel.fromJson(Map<String, dynamic> json) {
    return RepaymentModel(
      loanId: json['loan_id'] ?? '',
      uid: json['uid'] ?? '',
      month: json['month'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      dueDate: json['due_date'] ?? '',
      status: json['status'] ?? 'upcoming',
      penalty: (json['penalty'] ?? 0).toDouble(),
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loan_id': loanId,
      'uid': uid,
      'month': month,
      'amount': amount,
      'due_date': dueDate,
      'status': status,
      'penalty': penalty,
      'paid_at': paidAt?.toIso8601String(),
    };
  }

  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isUpcoming => status == 'upcoming';
  bool get isOverdue => status == 'overdue';
}

class LoanApplicationInput {
  final double loanAmount;
  final int loanDurationMonths;
  final String purpose;
  final double rateOfInterest;
  final bool disclaimerAccepted;

  LoanApplicationInput({
    required this.loanAmount,
    required this.loanDurationMonths,
    required this.purpose,
    required this.rateOfInterest,
    required this.disclaimerAccepted,
  });

  Map<String, dynamic> toJson() {
    return {
      'loan_amount': loanAmount,
      'loan_duration_months': loanDurationMonths,
      'purpose': purpose,
      'rate_of_interest': rateOfInterest,
      'disclaimer_accepted': disclaimerAccepted,
    };
  }
}
