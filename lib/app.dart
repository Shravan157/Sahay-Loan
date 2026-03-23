import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/loan_provider.dart';
import 'providers/kyc_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/document_provider.dart';
import 'providers/provider_admin_provider.dart';
import 'providers/payment_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/provider_register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/user/home_screen.dart';
import 'screens/user/profile_screen.dart';
import 'screens/user/notifications_screen.dart';
import 'screens/user/kyc_screen.dart';
import 'screens/user/credit_score_screen.dart';
import 'screens/user/apply_loan_screen.dart';
import 'screens/user/my_loans_screen.dart';
import 'screens/user/loan_detail_screen.dart';
import 'screens/user/repayment_schedule_screen.dart';
import 'screens/user/pay_emi_screen.dart';
import 'screens/user/settings_screen.dart';
import 'screens/user/help_support_screen.dart';
import 'screens/user/terms_and_privacy_screen.dart';
import 'screens/payment/payment_history_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/all_loans_screen.dart';
import 'screens/admin/add_company_screen.dart';
import 'screens/admin/provider_verification_screen.dart';
import 'screens/admin/all_users_screen.dart';
import 'screens/provider/provider_dashboard_screen.dart';

class SahayApp extends StatelessWidget {
  const SahayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LoanProvider()),
        ChangeNotifierProvider(create: (_) => KYCProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => ProviderAdminProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: MaterialApp(
        title: 'SAHAY',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/home': (context) => const MainNavigationScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/help-support': (context) => const HelpSupportScreen(),
          '/terms': (context) => const TermsAndPrivacyScreen(isTerms: true),
          '/privacy': (context) => const TermsAndPrivacyScreen(isTerms: false),
          '/notifications': (context) => const NotificationsScreen(),
          '/kyc': (context) => const KYCScreen(),
          '/credit-score': (context) => const CreditScoreScreen(),
          '/apply-loan': (context) => const ApplyLoanScreen(),
          '/my-loans': (context) => const MyLoansScreen(),
          '/loan-detail': (context) {
            final loanId =
                ModalRoute.of(context)?.settings.arguments as String?;
            return LoanDetailScreen(loanId: loanId ?? '');
          },
          '/repayment-schedule': (context) {
            final loanId =
                ModalRoute.of(context)?.settings.arguments as String?;
            return RepaymentScheduleScreen(loanId: loanId ?? '');
          },
          '/pay-emi': (context) {
            final args =
                ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>?;
            return PayEMIScreen(
              loanId: args?['loanId'] ?? '',
              month: args?['month'] ?? 1,
              amount: args?['amount'] ?? 0.0,
            );
          },
          '/payment-history': (context) {
            final loanId =
                ModalRoute.of(context)?.settings.arguments as String?;
            return PaymentHistoryScreen(loanId: loanId);
          },
          '/admin/dashboard': (context) => const AdminDashboardScreen(),
          '/admin/loans': (context) => const AllLoansScreen(),
          '/admin/add-company': (context) => const AddCompanyScreen(),
          '/admin/provider-verification': (context) =>
              const ProviderVerificationScreen(),
          '/admin/users': (context) => const AllUsersScreen(),
          '/provider/dashboard': (context) => const ProviderDashboardScreen(),
          '/provider/register': (context) => const ProviderRegisterScreen(),
        },
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MyLoansScreen(),
    const _PayEmiTab(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Loans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_outlined),
            activeIcon: Icon(Icons.payment),
            label: 'Pay EMI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Pay EMI tab shows the user's active loan EMI or a redirect to My Loans
class _PayEmiTab extends StatelessWidget {
  const _PayEmiTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pay EMI')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B4FFF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payment,
                  size: 50,
                  color: Color(0xFF1B4FFF),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Pay Your EMI',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Go to your loan details to pay an EMI. Select a loan from the Loans tab to get started.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/my-loans');
                  },
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  label: const Text('View My Loans'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
