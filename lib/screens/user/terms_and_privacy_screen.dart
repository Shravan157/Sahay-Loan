import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class TermsAndPrivacyScreen extends StatelessWidget {
  final bool isTerms;

  const TermsAndPrivacyScreen({super.key, this.isTerms = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(context),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: isTerms ? _buildTerms(context) : _buildPrivacy(context),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        isTerms ? 'Terms of Service' : 'Privacy Policy',
        style: const TextStyle(
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
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.25)),
                        ),
                        child: Icon(
                          isTerms
                              ? Icons.description_outlined
                              : Icons.privacy_tip_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isTerms ? 'Terms of Service' : 'Privacy Policy',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last updated: March 2025',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 12,
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

  Widget _buildTerms(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          context,
          number: '01',
          title: 'Acceptance of Terms',
          content:
          'By accessing or using SAHAY\'s loan application services, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our services.',
        ),
        _buildSection(
          context,
          number: '02',
          title: 'Eligibility',
          content:
          'To use SAHAY\'s services, you must:\n• Be at least 18 years of age\n• Be a citizen or permanent resident of India\n• Have a valid Aadhaar card and PAN card\n• Have a consistent source of income\n• Not be a declared insolvent',
        ),
        _buildSection(
          context,
          number: '03',
          title: 'Loan Application Process',
          content:
          'When you apply for a loan through SAHAY:\n• You authorize us to collect and verify your personal and financial information\n• Your application will undergo credit scoring using our AI-powered system\n• Loan approval is at the sole discretion of our partner lending institutions\n• Interest rates are determined based on your credit score and risk assessment',
        ),
        _buildSection(
          context,
          number: '04',
          title: 'KYC Verification',
          content:
          'You agree to:\n• Provide accurate and authentic KYC documents\n• Allow SAHAY to verify your Aadhaar and PAN information\n• Accept that providing false information is grounds for immediate rejection and may result in legal action\n• Update your information promptly if it changes',
        ),
        _buildSection(
          context,
          number: '05',
          title: 'Repayment Obligations',
          content:
          'As a borrower, you agree to:\n• Repay the loan amount along with applicable interest as per the agreed EMI schedule\n• Make payments on or before the due date\n• Accept that late payments may attract penalties\n• Understand that default may negatively impact your credit score',
        ),
        _buildSection(
          context,
          number: '06',
          title: 'Data Usage',
          content:
          'SAHAY collects and uses your personal data to:\n• Process your loan application\n• Verify your identity and creditworthiness\n• Share relevant information with our partner lenders (with your consent)\n• Improve our services and personalize your experience\n• Comply with regulatory requirements',
        ),
        _buildSection(
          context,
          number: '07',
          title: 'Prohibited Activities',
          content:
          'You agree not to:\n• Use our services for any illegal purpose\n• Provide false or misleading information\n• Attempt to circumvent our security measures\n• Use borrowed funds for prohibited activities as defined by Indian law',
        ),
        _buildSection(
          context,
          number: '08',
          title: 'Limitation of Liability',
          content:
          'SAHAY shall not be liable for any indirect, incidental, special, or consequential damages arising out of your use of our services. Our total liability shall not exceed the fees paid by you for the service in the preceding 12 months.',
        ),
        _buildSection(
          context,
          number: '09',
          title: 'Governing Law',
          content:
          'These terms are governed by and construed in accordance with the laws of India. Any disputes shall be subject to the exclusive jurisdiction of courts in Bangalore, Karnataka.',
        ),
        _buildSection(
          context,
          number: '10',
          title: 'Contact Us',
          content:
          'For questions about these Terms of Service, contact us at:\n📧 legal@sahayloans.in\n📞 1800-XXX-XXXX (Toll Free)\n🕐 Monday to Saturday, 9 AM - 6 PM IST',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildPrivacy(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          context,
          number: '01',
          title: 'Information We Collect',
          content:
          'We collect the following types of information:\n\n• Personal Information: Name, email, phone number, date of birth\n• Identity Documents: Aadhaar card, PAN card images and extracted data\n• Financial Information: Income, employment details, loan history\n• Device Information: Device ID, IP address, app usage data\n• Location Data: Only when you grant permission',
        ),
        _buildSection(
          context,
          number: '02',
          title: 'How We Use Your Information',
          content:
          'Your information is used to:\n• Verify your identity and process loan applications\n• Assess your creditworthiness using AI-powered models\n• Connect you with appropriate lending partners\n• Send you important notifications about your account\n• Improve our products and services\n• Comply with legal and regulatory obligations',
        ),
        _buildSection(
          context,
          number: '03',
          title: 'Information Sharing',
          content:
          'We share your information with:\n• Partner Lending Institutions (with your explicit consent via Phase 1/Phase 2 system)\n• KYC verification agencies\n• Payment processors for EMI collection\n• Regulatory authorities as required by law\n\nWe do NOT sell your personal data to third parties or use it for marketing.',
        ),
        _buildSection(
          context,
          number: '04',
          title: 'Two-Phase Data Sharing',
          content:
          'SAHAY uses a privacy-first two-phase data sharing model:\n\n• Phase 1: Only anonymized financial data shared (no Aadhaar, PAN, phone, or email)\n• Phase 2: Full details shared only upon explicit approval by SAHAY admin and your knowledge\n\nThis ensures your sensitive data is protected at all times.',
        ),
        _buildSection(
          context,
          number: '05',
          title: 'Data Security',
          content:
          'We protect your data through:\n• End-to-end encryption for sensitive document transmission\n• Firebase Authentication for secure login\n• Encrypted storage of personal documents\n• Regular security audits and penetration testing\n• Strict access controls for our team',
        ),
        _buildSection(
          context,
          number: '06',
          title: 'Your Rights',
          content:
          'You have the right to:\n• Access your personal data we hold\n• Correct inaccurate information\n• Request deletion of your account and data\n• Withdraw consent for data processing (may affect service availability)\n• Lodge complaints with the Data Protection Authority',
        ),
        _buildSection(
          context,
          number: '07',
          title: 'Data Retention',
          content:
          'We retain your data for:\n• Active accounts: Duration of account + 7 years (as per RBI guidelines)\n• Loan records: 10 years after loan closure\n• Deleted accounts: 30 days before permanent deletion',
        ),
        _buildSection(
          context,
          number: '08',
          title: 'Cookies and Tracking',
          content:
          'Our app may use:\n• Session tokens for authentication\n• Analytics to improve user experience\n• Crash reporting tools\n\nYou can control analytics settings in your Profile settings.',
        ),
        _buildSection(
          context,
          number: '09',
          title: 'Children\'s Privacy',
          content:
          'SAHAY is not intended for individuals under 18 years of age. We do not knowingly collect personal information from minors.',
        ),
        _buildSection(
          context,
          number: '10',
          title: 'Contact for Privacy Concerns',
          content:
          'For privacy-related queries or to exercise your rights:\n📧 privacy@sahayloans.in\n📞 1800-XXX-XXXX (Toll Free)\n📍 Data Protection Officer, SAHAY Financial Services Pvt. Ltd.\nBangalore, Karnataka, India - 560001',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildSection(
      BuildContext context, {
        required String number,
        required String title,
        required String content,
        bool isLast = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  number,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Content card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 13,
              height: 1.75,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        if (!isLast) ...[
          const SizedBox(height: 6),
          // Connector line
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Container(
              width: 2,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          const SizedBox(height: 6),
        ] else
          const SizedBox(height: 8),
      ],
    );
  }
}