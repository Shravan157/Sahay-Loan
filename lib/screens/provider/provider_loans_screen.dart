import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../providers/provider_admin_provider.dart';

class ProviderLoansScreen extends StatefulWidget {
  const ProviderLoansScreen({super.key});

  @override
  State<ProviderLoansScreen> createState() => _ProviderLoansScreenState();
}

class _ProviderLoansScreenState extends State<ProviderLoansScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    await context.read<ProviderAdminProvider>().loadSharedProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Loan Applications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfiles,
          ),
        ],
      ),
      body: Consumer<ProviderAdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final profiles = provider.sharedProfiles;
          final approvedCount = profiles.where((p) => p.isApproved).length;
          final pendingCount = profiles.where((p) => p.isPending).length;

          return RefreshIndicator(
            onRefresh: _loadProfiles,
            child: Column(
              children: [
                _buildStatsHeader(profiles.length, approvedCount, pendingCount),
                Expanded(
                  child: profiles.isEmpty
                      ? const Center(child: Text('No loan applications shared yet'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: profiles.length,
                          itemBuilder: (context, index) {
                            final profile = profiles[index];
                            return _ProfileCard(
                              profile: profile,
                              onRequestDetails: profile.isPhase1
                                  ? () => _showRequestDetailsDialog(profile)
                                  : null,
                              onMakeDecision: profile.isPhase2
                                  ? () => _showDecisionDialog(profile)
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsHeader(int total, int approved, int pending) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem('Total Shared', total.toString(), AppColors.primary),
          _buildStatItem('Approved', approved.toString(), AppColors.success),
          _buildStatItem('Pending', pending.toString(), Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }


  void _showRequestDetailsDialog(SharedLoanProfile profile) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Full Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Request full KYC details for ${profile.userName}?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'Why do you need full details?',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _requestDetails(profile, reasonController.text);
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  Future<void> _requestDetails(SharedLoanProfile profile, String reason) async {
    final provider = context.read<ProviderAdminProvider>();
    final success = await provider.requestFullDetails(
      profile.shareId,
      reason,
    );

    if (success && mounted) {
      Helpers.showSnackBar(
        context,
        message: 'Full details requested',
        isSuccess: true,
      );
    }
  }

  void _showDecisionDialog(SharedLoanProfile profile) {
    final rateController = TextEditingController();
    final reasonController = TextEditingController();
    String decision = 'approved';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Loan Decision'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Decision toggle
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Approve'),
                        selected: decision == 'approved',
                        onSelected: (_) => setState(() => decision = 'approved'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Reject'),
                        selected: decision == 'rejected',
                        onSelected: (_) => setState(() => decision = 'rejected'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Interest rate (only for approval)
                if (decision == 'approved')
                  TextField(
                    controller: rateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Offered Interest Rate (%)',
                      hintText: 'e.g., 12.5',
                    ),
                  ),
                const SizedBox(height: 16),
                // Reason
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason/Notes',
                    hintText: 'Add any comments...',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                final rate = double.tryParse(rateController.text);
                _makeDecision(
                  profile,
                  decision,
                  reasonController.text,
                  rate,
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeDecision(
    SharedLoanProfile profile,
    String decision,
    String reason,
    double? rate,
  ) async {
    final provider = context.read<ProviderAdminProvider>();
    final success = await provider.makeLoanDecision(
      shareId: profile.shareId,
      decision: decision,
      reason: reason.isEmpty ? null : reason,
      offeredInterestRate: decision == 'approved' ? rate : null,
    );

    if (success && mounted) {
      Helpers.showSnackBar(
        context,
        message: decision == 'approved'
            ? 'Loan approved successfully'
            : 'Loan rejected',
        isSuccess: true,
      );
    }
  }
}

class _ProfileCard extends StatelessWidget {
  final SharedLoanProfile profile;
  final VoidCallback? onRequestDetails;
  final VoidCallback? onMakeDecision;

  const _ProfileCard({
    required this.profile,
    this.onRequestDetails,
    this.onMakeDecision,
  });

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
                Expanded(
                  child: Text(
                    profile.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _buildStatusChip(profile.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              profile.userEmail,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const Divider(height: 24),
            _buildInfoRow('Loan Amount', '₹${profile.loanAmount.toStringAsFixed(0)}'),
            _buildInfoRow('Duration', '${profile.loanDuration} months'),
            _buildInfoRow('Purpose', profile.purpose),
            _buildInfoRow('User Requested Rate', '${profile.userRequestedRate}%'),
            if (profile.offeredInterestRate != null)
              _buildInfoRow(
                'Your Offered Rate',
                '${profile.offeredInterestRate}%',
                valueColor: AppColors.success,
              ),
            const SizedBox(height: 12),
            // Action buttons
            if (profile.isPhase1)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: profile.phase2Requested ? null : onRequestDetails,
                  child: Text(profile.phase2Requested
                      ? 'Full Details Requested'
                      : 'Request Full Details'),
                ),
              ),
            if (profile.isPhase2)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onMakeDecision,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                  child: const Text('Make Decision'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'pending':
      case 'phase1_shared':
        if (profile.phase2Requested) {
          color = Colors.orange;
          label = 'Phase 2 Requested';
        } else {
          color = Colors.orange;
          label = 'Phase 1';
        }
        break;
      case 'phase2_shared':
        color = Colors.blue;
        label = 'Full Details Shared';
        break;
      case 'approved':
        color = AppColors.success;
        label = 'Approved';
        break;
      case 'rejected':
        color = AppColors.error;
        label = 'Rejected';
        break;
      default:
        color = Colors.grey;
        label = status.toUpperCase();
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
