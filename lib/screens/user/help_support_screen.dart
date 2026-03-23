import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contact cards
              Row(
                children: [
                  Expanded(
                    child: _buildContactCard(
                      icon: Icons.phone_outlined,
                      title: 'Call Us',
                      subtitle: '1800-XXX-XXXX',
                      caption: 'Mon–Sat · 9AM–6PM',
                      color: const Color(0xFF22C55E),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildContactCard(
                      icon: Icons.email_outlined,
                      title: 'Email Us',
                      subtitle: 'support@',
                      caption: 'sahayloans.in',
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),
              _buildSectionLabel('Frequently Asked Questions'),
              const SizedBox(height: 12),

              _buildFaqItem(
                question: 'How do I apply for a loan?',
                answer:
                'To apply for a loan:\n1. Complete your KYC verification (Aadhaar + PAN)\n2. Check your credit score on the Credit Score screen\n3. Go to "Apply Loan" from the home screen\n4. Select loan amount, tenure, and purpose\n5. Review the EMI and submit your application\n\nYour application will be reviewed within 24-48 hours.',
              ),
              _buildFaqItem(
                question: 'What documents do I need for KYC?',
                answer:
                'For KYC verification, you need:\n• Aadhaar Card (front side with barcode)\n• PAN Card\n\nMake sure the documents are clear, not expired, and match your registration details.',
              ),
              _buildFaqItem(
                question: 'How is my credit score calculated?',
                answer:
                'Your SAHAY credit score is calculated using our AI-powered model that considers:\n• Annual income and monthly salary\n• Occupation and employment stability\n• Outstanding debt (if any)\n• Previous loan history\n\nScore ranges:\n• 700+ = Excellent\n• 600-699 = Good\n• Below 600 = Fair',
              ),
              _buildFaqItem(
                question: 'What are the loan interest rates?',
                answer:
                'Interest rates are based on your credit score:\n• Credit score 700+: Starting from 10.5% p.a.\n• Credit score 600-699: 12-15% p.a.\n• Credit score below 600: 15-18% p.a.\n\nFinal rates are determined by our partner lending institutions.',
              ),
              _buildFaqItem(
                question: 'How and when should I pay EMIs?',
                answer:
                'EMI payments can be made through the app:\n1. Go to "Pay EMI" tab or the loan detail screen\n2. Select the EMI you want to pay\n3. Pay using card (Visa/Mastercard/RuPay)\n\nEMIs are due on the same date each month as your disbursement date.',
              ),
              _buildFaqItem(
                question: 'What happens if I miss an EMI payment?',
                answer:
                'Missing an EMI may result in:\n• Late payment penalty charges\n• Negative impact on your credit score\n• Loan being marked as "overdue"\n• If 3+ EMIs are missed, your account may be flagged as a defaulter\n\nContact us immediately if you anticipate difficulty.',
              ),
              _buildFaqItem(
                question: 'How long does loan approval take?',
                answer:
                'The approval process typically takes:\n• KYC Verification: 1-2 business days\n• Credit Assessment: Instant (AI-powered)\n• Provider Review: 2-5 business days\n• Final Approval & Disbursement: 1-2 business days\n\nTotal estimated time: 5-10 business days',
              ),
              _buildFaqItem(
                question: 'Is my data secure with SAHAY?',
                answer:
                'Yes, your data security is our top priority:\n• All data is encrypted end-to-end\n• Documents are stored in secure cloud storage\n• We use Firebase Authentication (Google\'s enterprise-grade security)\n• We never sell your data to third parties\n\nRead our full Privacy Policy for more details.',
              ),
              _buildFaqItem(
                question: 'How do I change my password?',
                answer:
                'To change your password:\n1. Go to Profile > Settings\n2. Select "Change Password"\n3. Enter your current password\n4. Enter and confirm your new password\n\nAlternatively, use "Forgot Password?" on the login screen to reset via email.',
              ),
              _buildFaqItem(
                question: 'Can I cancel my loan application?',
                answer:
                'You can withdraw a pending application by contacting support:\n• Email: support@sahayloans.in\n• Call: 1800-XXX-XXXX\n• Provide your Loan ID from the My Loans screen\n\nOnce a loan is disbursed, it cannot be cancelled.',
              ),

              const SizedBox(height: 28),

              // Still need help card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Still need help?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Our support team is available\nMonday to Saturday, 9 AM – 6 PM IST',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Redirecting to support: support@sahayloans.in'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.email_outlined,
                            size: 18, color: Colors.white),
                        label: const Text(
                          'Email Support',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: const Text(
        'Help & Support',
        style: TextStyle(
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
                      const Text(
                        'How can we help you?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Find answers or reach out to our team',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
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

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String caption,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0F172A),
            ),
          ),
          Text(
            caption,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          childrenPadding:
          const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          iconColor: AppColors.primary,
          collapsedIconColor: const Color(0xFF94A3B8),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.7,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}