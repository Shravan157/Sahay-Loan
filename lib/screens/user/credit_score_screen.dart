import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/helpers.dart';
import '../../models/credit_score_model.dart';
import '../../providers/loan_provider.dart';

class CreditScoreScreen extends StatefulWidget {
  const CreditScoreScreen({super.key});

  @override
  State<CreditScoreScreen> createState() => _CreditScoreScreenState();
}

class _CreditScoreScreenState extends State<CreditScoreScreen> {
  bool _isLoading = false;
  String? _creditScore;
  bool? _isEligible;
  double? _maxLoanAmount;

  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController();
  final _expensesController = TextEditingController();
  final _savingsController = TextEditingController();
  final _dependentsController = TextEditingController();
  final _existingLoansController = TextEditingController();

  String _employmentType = 'Salaried';
  String _maritalStatus = 'Single';

  final List<String> _employmentTypes = [
    'Salaried',
    'Self-Employed',
    'Business Owner',
    'Freelancer',
    'Unemployed',
  ];

  final List<String> _maritalStatuses = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
  ];

  @override
  void dispose() {
    _incomeController.dispose();
    _expensesController.dispose();
    _savingsController.dispose();
    _dependentsController.dispose();
    _existingLoansController.dispose();
    super.dispose();
  }

  Future<void> _checkCreditScore() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final loanProvider = Provider.of<LoanProvider>(context, listen: false);

    final monthlyIncome = double.parse(_incomeController.text);
    final monthlyExpenses = double.parse(_expensesController.text);
    final savings = double.parse(_savingsController.text);
    final existingLoans = double.parse(_existingLoansController.text);

    final input = CreditScoreInput(
      annualIncome: monthlyIncome * 12,
      monthlyInhandSalary: monthlyIncome,
      numBankAccounts: 1,
      numCreditCard: 0,
      interestRate: 12.5,
      numOfLoan: existingLoans > 0 ? 1 : 0,
      delayFromDueDate: 0,
      numOfDelayedPayment: 0,
      changedCreditLimit: 0,
      numCreditInquiries: 0,
      outstandingDebt: existingLoans,
      creditHistoryAge: 12,
      totalEmiPerMonth: existingLoans,
      amountInvestedMonthly: savings * 0.01,
      monthlyBalance: monthlyIncome - monthlyExpenses,
      creditMixLabel: 1,
      paymentOfMinAmountLabel: 0,
      typeOfLoanLabel: 0,
    );

    final success = await loanProvider.predictCreditScore(input);

    if (success && mounted) {
      setState(() {
        _creditScore = loanProvider.creditScore?.creditScore;
        _isEligible = loanProvider.creditScore?.eligible;
        _maxLoanAmount = loanProvider.creditScore?.eligible == true ? 50000 : 0;
      });
    }

    setState(() => _isLoading = false);
  }

  Color _getScoreColor(String score) {
    switch (score.toLowerCase()) {
      case 'good':
        return const Color(0xFF22C55E);
      case 'standard':
        return const Color(0xFFF97316);
      case 'poor':
        return const Color(0xFFEF4444);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Result card shown above form if score available
                if (_creditScore != null) ...[
                  _buildResultCard(),
                  const SizedBox(height: 28),
                ],

                _buildSectionLabel('Financial Information'),
                const SizedBox(height: 10),
                _buildCard(children: [
                  _buildInputField(
                    controller: _incomeController,
                    label: 'Monthly Income',
                    hint: 'e.g. 50,000',
                    prefix: '₹',
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _expensesController,
                    label: 'Monthly Expenses',
                    hint: 'e.g. 25,000',
                    prefix: '₹',
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _savingsController,
                    label: 'Total Savings',
                    hint: 'e.g. 1,00,000',
                    prefix: '₹',
                  ),
                ]),

                const SizedBox(height: 24),
                _buildSectionLabel('Personal Information'),
                const SizedBox(height: 10),
                _buildCard(children: [
                  _buildDropdownField(
                    label: 'Employment Type',
                    value: _employmentType,
                    items: _employmentTypes,
                    onChanged: (value) =>
                        setState(() => _employmentType = value!),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'Marital Status',
                    value: _maritalStatus,
                    items: _maritalStatuses,
                    onChanged: (value) =>
                        setState(() => _maritalStatus = value!),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _dependentsController,
                    label: 'Number of Dependents',
                    hint: 'e.g. 2',
                  ),
                ]),

                const SizedBox(height: 24),
                _buildSectionLabel('Existing Obligations'),
                const SizedBox(height: 10),
                _buildCard(children: [
                  _buildInputField(
                    controller: _existingLoansController,
                    label: 'Existing EMI (Monthly)',
                    hint: 'e.g. 5,000',
                    prefix: '₹',
                  ),
                ]),

                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 190,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Credit Score',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'AI-Powered Credit Assessment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Know your eligibility in seconds',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final scoreColor = _getScoreColor(_creditScore ?? '');
    final isEligible = _isEligible ?? false;

    String explanation;
    switch (_creditScore?.toLowerCase()) {
      case 'good':
        explanation =
        'Excellent credit profile! You have a strong repayment capacity and are eligible for higher loan amounts.';
        break;
      case 'standard':
        explanation =
        'Fair credit profile. You are eligible for moderate loan amounts. Consider improving your savings.';
        break;
      case 'poor':
        explanation =
        'Limited credit profile. We recommend improving your financial stability before applying.';
        break;
      default:
        explanation = 'Credit score assessment completed.';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Score badge row
          Row(
            children: [
              // Score circle
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scoreColor.withOpacity(0.1),
                  border: Border.all(color: scoreColor.withOpacity(0.3), width: 2),
                ),
                child: Center(
                  child: Text(
                    (_creditScore ?? '').toUpperCase(),
                    style: TextStyle(
                      color: scoreColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isEligible
                            ? const Color(0xFF22C55E).withOpacity(0.1)
                            : const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isEligible
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: isEligible
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFEF4444),
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isEligible ? 'Eligible for Loan' : 'Not Eligible',
                            style: TextStyle(
                              color: isEligible
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFEF4444),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isEligible && _maxLoanAmount != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Up to ${Formatters.formatCurrency(_maxLoanAmount!)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Maximum loan amount',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Explanation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              explanation,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.grey[600],
              ),
            ),
          ),

          if (isEligible) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/apply-loan'),
                icon: const Icon(Icons.arrow_forward_rounded,
                    size: 18, color: Colors.white),
                label: const Text(
                  'Apply for Loan',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? prefix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 13,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w500,
        ),
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
        prefixText: prefix,
        prefixStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
          fontSize: 14,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (double.tryParse(value) == null) return 'Enter valid number';
        return null;
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF0F172A),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF64748B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 13,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _checkCreditScore,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
              strokeWidth: 2.5, color: Colors.white),
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.electric_bolt_rounded,
                color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Check My Credit Score',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}