import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/loan_provider.dart';
import 'providers/kyc_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/user/home_screen.dart';
import 'screens/user/profile_screen.dart';
import 'screens/user/notifications_screen.dart';
import 'screens/user/kyc_screen.dart';
import 'screens/user/credit_score_screen.dart';
import 'screens/user/apply_loan_screen.dart';
import 'screens/user/my_loans_screen.dart';
import 'screens/user/loan_detail_screen.dart';
import 'screens/user/repayment_schedule_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/all_loans_screen.dart';
import 'screens/admin/add_company_screen.dart';
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
          '/home': (context) => const MainNavigationScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/kyc': (context) => const KYCScreen(),
          '/credit-score': (context) => const CreditScoreScreen(),
          '/apply-loan': (context) => const ApplyLoanScreen(),
          '/my-loans': (context) => const MyLoansScreen(),
          '/loan-detail': (context) {
            final loanId = ModalRoute.of(context)?.settings.arguments as String?;
            return LoanDetailScreen(loanId: loanId ?? '');
          },
          '/repayment-schedule': (context) {
            final loanId = ModalRoute.of(context)?.settings.arguments as String?;
            return RepaymentScheduleScreen(loanId: loanId ?? '');
          },
          '/admin/dashboard': (context) => const AdminDashboardScreen(),
          '/admin/loans': (context) => const AllLoansScreen(),
          '/admin/add-company': (context) => const AddCompanyScreen(),
          '/provider/dashboard': (context) => const ProviderDashboardScreen(),
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
    const Center(child: Text('Pay EMI')), // Placeholder
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
