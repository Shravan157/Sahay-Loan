import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/loan_model.dart';
import '../../providers/admin_provider.dart';

class AllLoansScreen extends StatefulWidget {
  const AllLoansScreen({super.key});

  @override
  State<AllLoansScreen> createState() => _AllLoansScreenState();
}

class _AllLoansScreenState extends State<AllLoansScreen> {
  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  Future<void> _loadLoans() async {
    final adminProvider = context.read<AdminProvider>();
    await adminProvider.loadAllLoans();
    await adminProvider.loadAllCompanies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Loans'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadLoans),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final loans = adminProvider.allLoans;

          if (loans.isEmpty) {
            return const Center(child: Text('No loans found'));
          }

          return RefreshIndicator(
            onRefresh: _loadLoans,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: loans.length,
              itemBuilder: (context, index) {
                final loan = loans[index];
                return _LoanCard(
                  loan: loan,
                  onShare: () => _showShareDialog(loan),
                  onDisburse: loan.isApproved
                      ? () => _disburseLoan(loan)
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showShareDialog(LoanModel loan) {
    final adminProvider = context.read<AdminProvider>();
    final companies = adminProvider.companies;
    String? selectedCompanyId;

    if (companies.isEmpty) {
      Helpers.showSnackBar(
        context,
        message: 'No lending partners found. Please add a company first.',
        isError: true,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Share to Lending Partner'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a lending partner to share Loan #${loan.loanId.substring(0, 8)} with:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCompanyId,
                hint: const Text('Select Lending Partner'),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.business_outlined),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: companies.map((company) {
                  return DropdownMenuItem<String>(
                    value: company.id,
                    child: Text(
                      '${company.name} (${company.type})',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
                onChanged: (val) =>
                    setDialogState(() => selectedCompanyId = val),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Phase 1 data (no Aadhaar/PAN) will be shared initially.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedCompanyId == null
                  ? null
                  : () {
                      final cId = selectedCompanyId!;
                      Navigator.pop(dialogContext);
                      _shareLoan(loan, cId);
                    },
              child: const Text('Share (Phase 1)'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareLoan(LoanModel loan, String companyId) async {
    final adminProvider = context.read<AdminProvider>();
    final success = await adminProvider.sharePhase1(loan.loanId, companyId);

    if (success && mounted) {
      Helpers.showSnackBar(
        context,
        message: 'Loan shared to provider (Phase 1)',
        isSuccess: true,
      );
    } else if (!success && mounted) {
      Helpers.showSnackBar(
        context,
        message: adminProvider.error ?? 'Failed to share loan',
        isError: true,
      );
    }
  }

  Future<void> _disburseLoan(LoanModel loan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Disbursement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The loan provider has approved this application. Disburse the funds to the customer?',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined,
                      color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '₹${loan.loanAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Disburse Funds'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final adminProvider = context.read<AdminProvider>();
      final success = await adminProvider.disburseLoan(loan.loanId);

      if (success && mounted) {
        Helpers.showSnackBar(
          context,
          message: '₹${loan.loanAmount.toStringAsFixed(0)} disbursed successfully!',
          isSuccess: true,
        );
      } else if (!success && mounted) {
        Helpers.showSnackBar(
          context,
          message: adminProvider.error ?? 'Disbursement failed',
          isError: true,
        );
      }
    }
  }
}

class _LoanCard extends StatelessWidget {
  final LoanModel loan;
  final VoidCallback onShare;
  final VoidCallback? onDisburse;

  const _LoanCard({required this.loan, required this.onShare, this.onDisburse});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Loan #${loan.loanId.substring(0, 8)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildStatusChip(loan.status),
              ],
            ),
            const SizedBox(height: 8),
            Text('Amount: ₹${loan.loanAmount.toStringAsFixed(0)}'),
            Text('Duration: ${loan.durationMonths} months'),
            Text('Purpose: ${loan.purpose}'),
            const SizedBox(height: 12),
            Row(
              children: [
                if (loan.isPending || loan.isUnderReview)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onShare,
                      child: const Text('Share to Provider'),
                    ),
                  ),
                if (loan.isApproved && onDisburse != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onDisburse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                      ),
                      child: const Text('Disburse'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status.toLowerCase()) {
      case 'approved':
      case 'provider_approved':
        color = AppColors.success;
        label = 'Provider Approved';
        break;
      case 'rejected':
      case 'provider_rejected':
        color = AppColors.error;
        label = 'Rejected';
        break;
      case 'disbursed':
        color = Colors.blue;
        label = 'Disbursed';
        break;
      case 'shared_with_provider':
        color = Colors.purple;
        label = 'With Provider';
        break;
      case 'pending_sahay_review':
      case 'pending':
        color = Colors.orange;
        label = 'Pending Review';
        break;
      case 'completed':
        color = const Color(0xFF22C55E);
        label = 'Completed';
        break;
      default:
        color = Colors.grey;
        label = status.replaceAll('_', ' ').toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
