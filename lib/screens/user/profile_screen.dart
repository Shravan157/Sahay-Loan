import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await Helpers.showConfirmationDialog(
      context,
      title: AppStrings.logout,
      message: 'Are you sure you want to logout?',
      confirmText: AppStrings.logout,
      isDestructive: true,
    );

    if (!confirmed || !context.mounted) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final storage = StorageService();

    final userName = authProvider.user?.name ?? storage.getUserName() ?? 'User';
    final userEmail = authProvider.user?.email ?? storage.getUserEmail() ?? '';
    final kycVerified = userProvider.hasKYC || storage.getKycVerified();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [Helpers.getCardShadow()],
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        Helpers.getInitials(userName),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Name
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  // Email
                  Text(
                    userEmail,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Status Chips
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildStatusChip(
                        context,
                        icon: kycVerified ? Icons.verified : Icons.pending,
                        label: kycVerified
                            ? AppStrings.kycVerified
                            : AppStrings.kycPending,
                        color: kycVerified ? AppColors.success : AppColors.warning,
                      ),
                      if (authProvider.user?.role != null)
                        _buildStatusChip(
                          context,
                          icon: Icons.person_outline,
                          label: authProvider.user!.role.replaceAll('_', ' ').toUpperCase(),
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Menu Items
            _buildMenuSection(
              context,
              items: [
                _MenuItem(
                  icon: Icons.folder_outlined,
                  title: AppStrings.myDocuments,
                  onTap: () => Navigator.of(context).pushNamed('/kyc'),
                ),
                _MenuItem(
                  icon: Icons.history_outlined,
                  title: AppStrings.loanHistory,
                  onTap: () => Navigator.of(context).pushNamed('/my-loans'),
                ),
                _MenuItem(
                  icon: Icons.help_outline,
                  title: AppStrings.helpSupport,
                  onTap: () {
                    // TODO: Help & Support
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildMenuSection(
              context,
              items: [
                _MenuItem(
                  icon: Icons.privacy_tip_outlined,
                  title: AppStrings.privacyPolicy,
                  onTap: () {
                    // TODO: Privacy Policy
                  },
                ),
                _MenuItem(
                  icon: Icons.description_outlined,
                  title: AppStrings.termsConditions,
                  onTap: () {
                    // TODO: Terms & Conditions
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Logout Button
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [Helpers.getCardShadow()],
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: AppColors.error,
                ),
                title: Text(
                  AppStrings.logout,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                onTap: () => _logout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, {required List<_MenuItem> items}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [Helpers.getCardShadow()],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: AppColors.primary),
                title: Text(item.title),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
                onTap: item.onTap,
              ),
              if (index < items.length - 1)
                const Divider(height: 1, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
