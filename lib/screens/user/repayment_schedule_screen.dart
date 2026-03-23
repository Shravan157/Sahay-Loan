import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/loan_model.dart';
import '../../providers/loan_provider.dart';

class RepaymentScheduleScreen extends StatefulWidget {
  final String loanId;
  final bool isDisbursed;

  const RepaymentScheduleScreen({
    super.key,
    required this.loanId,
    this.isDisbursed = false,
  });

  @override
  State<RepaymentScheduleScreen> createState() =>
      _RepaymentScheduleScreenState();
}

class _RepaymentScheduleScreenState extends State<RepaymentScheduleScreen> {
  @override
  void initState() {
    super.initState();
    _loadRepaymentSchedule();
  }

  Future<void> _loadRepaymentSchedule() async {
    await Provider.of<LoanProvider>(context, listen: false)
        .loadRepaymentSchedule(widget.loanId);
  }

  void _payEMI(RepaymentModel repayment) {
    Navigator.pushNamed(
      context,
      '/pay-emi',
      arguments: {
        'loanId': widget.loanId,
        'month': repayment.month,
        'amount': repayment.amount,
      },
    ).then((_) => _loadRepaymentSchedule());
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const Color(0xFF22C55E);
      case 'pending':
        return const Color(0xFFF97316);
      case 'overdue':
        return const Color(0xFFEF4444);
      case 'upcoming':
        return AppColors.primary;
      default:
        return const Color(0xFF94A3B8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<LoanProvider>(
        builder: (context, loanProvider, child) {
          if (loanProvider.isLoading) {
            return const Scaffold(
              backgroundColor: Color(0xFFF8FAFC),
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          if (loanProvider.error != null) {
            return _buildErrorState(loanProvider.error!);
          }

          final repayments = loanProvider.repayments;
          if (repayments.isEmpty) {
            return _buildEmptyState();
          }

          final totalAmount =
          repayments.fold<double>(0, (sum, r) => sum + r.amount);
          final paidAmount = repayments
              .where((r) => r.isPaid)
              .fold<double>(0, (sum, r) => sum + r.amount);
          final pendingAmount = totalAmount - paidAmount;
          final paidCount = repayments.where((r) => r.isPaid).length;
          final totalCount = repayments.length;

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildSliverAppBar(
                paidCount: paidCount,
                totalCount: totalCount,
                totalAmount: totalAmount,
                pendingAmount: pendingAmount,
                paidAmount: paidAmount,
              ),
            ],
            body: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadRepaymentSchedule,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                itemCount: repayments.length,
                itemBuilder: (context, index) {
                  return _buildRepaymentCard(repayments[index]);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  SliverAppBar _buildSliverAppBar({
    required int paidCount,
    required int totalCount,
    required double totalAmount,
    required double pendingAmount,
    required double paidAmount,
  }) {
    final progress = totalCount > 0 ? paidCount / totalCount : 0.0;

    return SliverAppBar(
      expandedHeight: 280,
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
        'Repayment Schedule',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded,
              color: Colors.white, size: 20),
          onPressed: _loadRepaymentSchedule,
        ),
      ],
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
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: 60,
                left: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Stats row
                      Row(
                        children: [
                          Expanded(
                            child: _buildHeaderStat(
                              label: 'Total EMIs',
                              value: '$totalCount',
                              icon: Icons.calendar_month_rounded,
                            ),
                          ),
                          _buildHeaderDivider(),
                          Expanded(
                            child: _buildHeaderStat(
                              label: 'Paid',
                              value: '$paidCount',
                              icon: Icons.check_circle_rounded,
                            ),
                          ),
                          _buildHeaderDivider(),
                          Expanded(
                            child: _buildHeaderStat(
                              label: 'Pending',
                              value: '${totalCount - paidCount}',
                              icon: Icons.pending_rounded,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.15)),
                      const SizedBox(height: 20),

                      // Amount row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Amount',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                Formatters.formatCurrency(totalAmount),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Remaining',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                Formatters.formatCurrency(pendingAmount),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(progress * 100).toStringAsFixed(1)}% completed',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${totalCount - paidCount} EMIs left',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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

  Widget _buildHeaderStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderDivider() {
    return Container(
      width: 1,
      height: 48,
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildRepaymentCard(RepaymentModel repayment) {
    final statusColor = _getStatusColor(repayment.status);
    final isPaid = repayment.isPaid;
    final isOverdue = repayment.isOverdue;
    final isUpcoming = repayment.isUpcoming;
    final isPending = repayment.isPending;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue
              ? const Color(0xFFEF4444).withOpacity(0.25)
              : isUpcoming
              ? AppColors.primary.withOpacity(0.2)
              : const Color(0xFFE2E8F0),
          width: (isOverdue || isUpcoming) ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Month indicator
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isPaid
                    ? const Color(0xFF22C55E).withOpacity(0.1)
                    : statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isPaid
                      ? const Color(0xFF22C55E).withOpacity(0.3)
                      : statusColor.withOpacity(0.25),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'MO',
                    style: TextStyle(
                      fontSize: 9,
                      color: isPaid
                          ? const Color(0xFF22C55E)
                          : statusColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '${repayment.month}',
                    style: TextStyle(
                      fontSize: 18,
                      color: isPaid
                          ? const Color(0xFF22C55E)
                          : statusColor,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Formatters.formatCurrency(repayment.amount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Due: ${repayment.dueDate}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isOverdue
                          ? const Color(0xFFEF4444)
                          : Colors.grey[500],
                    ),
                  ),
                  if (repayment.penalty > 0) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.warning_rounded,
                            size: 12, color: Color(0xFFEF4444)),
                        const SizedBox(width: 4),
                        Text(
                          'Penalty: ${Formatters.formatCurrency(repayment.penalty)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Status / Action
            if (isPaid)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFF22C55E).withOpacity(0.25)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded,
                        color: Color(0xFF22C55E), size: 13),
                    SizedBox(width: 4),
                    Text(
                      'Paid',
                      style: TextStyle(
                        color: Color(0xFF22C55E),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            else if (isPending || isOverdue || isUpcoming)
              widget.isDisbursed
                  ? GestureDetector(
                      onTap: () => _payEMI(repayment),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isOverdue
                              ? const Color(0xFFEF4444)
                              : AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isOverdue ? 'Pay Now' : 'Pay',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'Awaiting\nDisbursal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border:
                  Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  'Upcoming',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Repayment Schedule',
          style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w600,
              fontSize: 17),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                  border:
                  Border.all(color: const Color(0xFFE2E8F0), width: 2),
                ),
                child: const Icon(Icons.error_outline_rounded,
                    color: Color(0xFFCBD5E1), size: 32),
              ),
              const SizedBox(height: 20),
              const Text(
                'Failed to load schedule',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Could not load repayment schedule. Please try again.',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loadRepaymentSchedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Repayment Schedule',
          style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w600,
              fontSize: 17),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                  border:
                  Border.all(color: const Color(0xFFE2E8F0), width: 2),
                ),
                child: const Icon(Icons.calendar_today_rounded,
                    color: Color(0xFFCBD5E1), size: 30),
              ),
              const SizedBox(height: 20),
              const Text(
                'No schedule found',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'No repayment schedule available for this loan.',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}