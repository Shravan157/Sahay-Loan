class CreditScoreModel {
  final String uid;
  final String creditScore;
  final bool eligible;
  final DateTime? calculatedAt;

  CreditScoreModel({
    required this.uid,
    required this.creditScore,
    required this.eligible,
    this.calculatedAt,
  });

  factory CreditScoreModel.fromJson(Map<String, dynamic> json) {
    return CreditScoreModel(
      uid: json['uid'] ?? '',
      creditScore: json['credit_score'] ?? '',
      eligible: json['eligible'] ?? false,
      calculatedAt: json['calculated_at'] != null
          ? DateTime.tryParse(json['calculated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'credit_score': creditScore,
      'eligible': eligible,
      'calculated_at': calculatedAt?.toIso8601String(),
    };
  }

  bool get isGood => creditScore.toLowerCase() == 'good';
  bool get isStandard => creditScore.toLowerCase() == 'standard';
  bool get isPoor => creditScore.toLowerCase() == 'poor';
}

class CreditScoreInput {
  final double annualIncome;
  final double monthlyInhandSalary;
  final double numBankAccounts;
  final double numCreditCard;
  final double interestRate;
  final double numOfLoan;
  final double delayFromDueDate;
  final double numOfDelayedPayment;
  final double changedCreditLimit;
  final double numCreditInquiries;
  final double outstandingDebt;
  final double creditHistoryAge;
  final double totalEmiPerMonth;
  final double amountInvestedMonthly;
  final double monthlyBalance;
  final int creditMixLabel;
  final int paymentOfMinAmountLabel;
  final int typeOfLoanLabel;

  CreditScoreInput({
    required this.annualIncome,
    required this.monthlyInhandSalary,
    required this.numBankAccounts,
    required this.numCreditCard,
    required this.interestRate,
    required this.numOfLoan,
    required this.delayFromDueDate,
    required this.numOfDelayedPayment,
    required this.changedCreditLimit,
    required this.numCreditInquiries,
    required this.outstandingDebt,
    required this.creditHistoryAge,
    required this.totalEmiPerMonth,
    required this.amountInvestedMonthly,
    required this.monthlyBalance,
    required this.creditMixLabel,
    required this.paymentOfMinAmountLabel,
    required this.typeOfLoanLabel,
  });

  Map<String, dynamic> toJson() {
    return {
      'Annual_Income': annualIncome,
      'Monthly_Inhand_Salary': monthlyInhandSalary,
      'Num_Bank_Accounts': numBankAccounts,
      'Num_Credit_Card': numCreditCard,
      'Interest_Rate': interestRate,
      'Num_of_Loan': numOfLoan,
      'Delay_from_due_date': delayFromDueDate,
      'Num_of_Delayed_Payment': numOfDelayedPayment,
      'Changed_Credit_Limit': changedCreditLimit,
      'Num_Credit_Inquiries': numCreditInquiries,
      'Outstanding_Debt': outstandingDebt,
      'Credit_History_Age': creditHistoryAge,
      'Total_EMI_per_month': totalEmiPerMonth,
      'Amount_invested_monthly': amountInvestedMonthly,
      'Monthly_Balance': monthlyBalance,
      'Credit_Mix_label': creditMixLabel,
      'Payment_of_Min_Amount_label': paymentOfMinAmountLabel,
      'Type_of_Loan_label': typeOfLoanLabel,
    };
  }

  factory CreditScoreInput.fromKYC({
    required double annualIncome,
    required double monthlyInhandSalary,
  }) {
    return CreditScoreInput(
      annualIncome: annualIncome,
      monthlyInhandSalary: monthlyInhandSalary,
      numBankAccounts: 1,
      numCreditCard: 0,
      interestRate: 12.5,
      numOfLoan: 0,
      delayFromDueDate: 0,
      numOfDelayedPayment: 0,
      changedCreditLimit: 0,
      numCreditInquiries: 0,
      outstandingDebt: 0,
      creditHistoryAge: 12,
      totalEmiPerMonth: 0,
      amountInvestedMonthly: monthlyInhandSalary * 0.1,
      monthlyBalance: monthlyInhandSalary * 0.3,
      creditMixLabel: 1,
      paymentOfMinAmountLabel: 0,
      typeOfLoanLabel: 0,
    );
  }
}

class CreditScoreResult {
  final String creditScore;
  final bool eligible;
  final String message;
  final String color;

  CreditScoreResult({
    required this.creditScore,
    required this.eligible,
    required this.message,
    required this.color,
  });

  factory CreditScoreResult.fromJson(Map<String, dynamic> json) {
    return CreditScoreResult(
      creditScore: json['credit_score'] ?? '',
      eligible: json['eligible'] ?? false,
      message: json['message'] ?? '',
      color: json['color'] ?? 'grey',
    );
  }
}
