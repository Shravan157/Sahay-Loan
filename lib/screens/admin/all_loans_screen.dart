import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class AllLoansScreen extends StatelessWidget {
  const AllLoansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.allLoans),
      ),
      body: const Center(
        child: Text('All Loans Screen - Coming Soon'),
      ),
    );
  }
}
