import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class RepaymentScheduleScreen extends StatelessWidget {
  final String loanId;

  const RepaymentScheduleScreen({super.key, required this.loanId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.repaymentSchedule),
      ),
      body: Center(
        child: Text('Repayment Schedule Screen - ID: $loanId'),
      ),
    );
  }
}
