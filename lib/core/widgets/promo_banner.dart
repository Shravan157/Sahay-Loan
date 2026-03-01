import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

class PromoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final IconData? icon;

  const PromoBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onTap,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              backgroundColor ?? AppColors.primary,
              (backgroundColor ?? AppColors.primary).withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (backgroundColor ?? AppColors.primary).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                  if (buttonText != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        buttonText!,
                        style: TextStyle(
                          color: backgroundColor ?? AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1, end: 0);
  }
}

class PromoCarousel extends StatefulWidget {
  final List<PromoBanner> banners;

  const PromoCarousel({
    super.key,
    required this.banners,
  });

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        final nextPage = (_currentPage + 1) % widget.banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              return widget.banners[index];
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? AppColors.primary
                    : AppColors.divider,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ReferralBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const ReferralBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return PromoBanner(
      title: 'Refer & Earn ₹500',
      subtitle: 'Invite friends to SAHAY and get ₹500 cashback',
      buttonText: 'Invite Now',
      backgroundColor: AppColors.secondary,
      icon: Icons.card_giftcard,
      onTap: onTap,
    );
  }
}

class CreditScoreBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const CreditScoreBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return PromoBanner(
      title: 'Check Your Credit Score',
      subtitle: 'Know your loan eligibility in seconds',
      buttonText: 'Check Now',
      backgroundColor: AppColors.accent,
      icon: Icons.trending_up,
      onTap: onTap,
    );
  }
}

class InsuranceBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const InsuranceBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return PromoBanner(
      title: 'Loan Insurance',
      subtitle: 'Protect your family with loan protection cover',
      buttonText: 'Learn More',
      backgroundColor: const Color(0xFF7B1FA2),
      icon: Icons.shield,
      onTap: onTap,
    );
  }
}

class GoldLoanBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const GoldLoanBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return PromoBanner(
      title: 'Gold Loan @ 7.5%',
      subtitle: 'Get instant loan against your gold jewelry',
      buttonText: 'Apply Now',
      backgroundColor: const Color(0xFFFF6F00),
      icon: Icons.monetization_on,
      onTap: onTap,
    );
  }
}
