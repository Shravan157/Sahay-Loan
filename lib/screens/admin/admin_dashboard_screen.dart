import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/document_provider.dart';
import '../../providers/provider_admin_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AdminProvider>().loadDashboardStats();
      context.read<AdminProvider>().loadSharedProfiles();
      context.read<DocumentProvider>().getPendingVerifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.adminDashboard),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<AdminProvider>().loadDashboardStats();
          await context.read<AdminProvider>().loadSharedProfiles();
          await context.read<DocumentProvider>().getPendingVerifications();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(),
              const SizedBox(height: 32),
              
              // Overview Section
              _buildSectionHeader('System Overview', null),
              const SizedBox(height: 16),
              Consumer<AdminProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _buildQuickStats(provider.dashboardStats);
                },
              ),
              const SizedBox(height: 32),

              // Quick Actions / Critical Tasks
              _buildSectionHeader('Critical Tasks', null),
              const SizedBox(height: 16),
              _buildCriticalTasksRow(context),
              const SizedBox(height: 32),

              // Core Management
              _buildSectionHeader('Management', null),
              const SizedBox(height: 16),
              _buildManagementGrid(context),
              const SizedBox(height: 32),

              // Activity Log
              _buildSectionHeader('Recent Activity', () {
                // View all activity logic
              }),
              const SizedBox(height: 16),
              _buildRecentActivity(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onTrailingTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        if (onTrailingTap != null)
          TextButton(
            onPressed: onTrailingTap,
            child: const Text('View All', style: TextStyle(fontSize: 14)),
          ),
      ],
    );
  }

  Widget _buildCriticalTasksRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Consumer<DocumentProvider>(
            builder: (context, docProvider, child) {
              final pendingCount = docProvider.pendingVerifications.length;
              return _buildTaskCard(
                icon: Icons.business,
                title: 'Provider\nVerification',
                count: pendingCount,
                color: Colors.orange,
                onTap: () => Navigator.pushNamed(context, '/admin/provider-verification'),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Consumer<AdminProvider>(
            builder: (context, adminProvider, child) {
              final pendingPhase2 = adminProvider.sharedProfiles
                  .where((p) => p.phase2Requested && !p.phase2Approved)
                  .length;
              return _buildTaskCard(
                icon: Icons.vpn_key,
                title: 'Phase 2\nRequests',
                count: pendingPhase2,
                color: AppColors.primary,
                onTap: () => _showPhase2RequestsDialog(context),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [Helpers.getCardShadow()],
          border: count > 0 ? Border.all(color: color.withOpacity(0.3), width: 2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildGridTile(
          icon: Icons.account_balance_wallet,
          title: 'All Loans',
          onTap: () => Navigator.pushNamed(context, '/admin/loans'),
        ),
        _buildGridTile(
          icon: Icons.add_business,
          title: 'Add Company',
          onTap: () => Navigator.pushNamed(context, '/admin/add-company'),
        ),
        _buildGridTile(
          icon: Icons.people,
          title: 'All Users',
          onTap: () => Navigator.pushNamed(context, '/admin/users'),
        ),
        _buildGridTile(
          icon: Icons.payment,
          title: 'Payments',
          onTap: () => Navigator.pushNamed(context, '/payment-history'),
        ),
      ],
    );
  }

  Widget _buildGridTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [Helpers.getCardShadow()],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, Admin',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        const Text(
          'SAHAY Dashboard',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildQuickStats(Map<String, dynamic>? stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.people,
            title: 'Total Users',
            value: (stats?['total_users'] ?? 0).toString(),
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.account_balance_wallet,
            title: 'Active Loans',
            value: (stats?['active_loans'] ?? 0).toString(),
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.pending_actions,
            title: 'Pending',
            value: (stats?['pending_loans'] ?? 0).toString(),
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [Helpers.getCardShadow()],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }





  Widget _buildRecentActivity() {
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        final recentLoans = provider.allLoans.take(3).toList();
        final recentUsers = provider.users.take(3).toList();
        
        if (recentLoans.isEmpty && recentUsers.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'No recent activity found',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
          );
        }

        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ...recentLoans.map((loan) => _buildActivityItem(
              icon: Icons.account_balance_wallet,
              title: 'New loan application',
              subtitle: '₹${loan.loanAmount.toStringAsFixed(0)} - ${loan.purpose}',
              time: 'Recent',
              color: AppColors.success,
            )),
            ...recentUsers.map((user) => _buildActivityItem(
              icon: Icons.person_add,
              title: 'New user registered',
              subtitle: user.email,
              time: 'Recent',
              color: AppColors.primary,
            )),
          ],
        );
      },
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [Helpers.getCardShadow()],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }

  void _showPhase2RequestsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<AdminProvider>(
        builder: (context, provider, child) {
          final requests = provider.sharedProfiles
              .where((p) => p.phase2Requested && !p.phase2Approved)
              .toList();

          return AlertDialog(
            title: const Text('Phase 2 Data Requests'),
            content: SizedBox(
              width: double.maxFinite,
              child: requests.isEmpty
                  ? const Text('No pending requests')
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final req = requests[index];
                        return ListTile(
                          title: Text('Loan #${req.loanId.substring(0, 8)}'),
                          subtitle: Text('Provider: ${req.shareId}'),
                          trailing: ElevatedButton(
                            onPressed: () => _approvePhase2(req),
                            child: const Text('Approve'),
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _approvePhase2(SharedLoanProfile profile) async {
    final success = await context.read<AdminProvider>().sharePhase2(
          profile.shareId,
          'company_id', // This is actually obtained from the share profile on backend
        );

    if (success && mounted) {
      Helpers.showSnackBar(
        context,
        message: 'Phase 2 data shared with provider',
        isSuccess: true,
      );
      context.read<AdminProvider>().loadSharedProfiles();
    }
  }
}
