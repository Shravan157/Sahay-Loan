import 'package:flutter/material.dart';

/// SAHAY Logo Widget - Based on mockup designs
/// Supports multiple variations: pill, badge, and stamp styles
class SahayLogo extends StatelessWidget {
  final double size;
  final bool showTagline;
  final bool showDevanagari;
  final SahayLogoStyle style;
  final Color? primaryColor;
  final Color? backgroundColor;

  const SahayLogo({
    super.key,
    this.size = 100,
    this.showTagline = true,
    this.showDevanagari = true,
    this.style = SahayLogoStyle.pillBadge,
    this.primaryColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case SahayLogoStyle.pillBadge:
        return _buildPillBadge();
      case SahayLogoStyle.bilingualBadge:
        return _buildBilingualBadge();
      case SahayLogoStyle.stampSeal:
        return _buildStampSeal();
      case SahayLogoStyle.minimal:
        return _buildMinimal();
    }
  }

  /// Pill Badge Style - Emerald green pill with S monogram
  Widget _buildPillBadge() {
    final primary = primaryColor ?? const Color(0xFF008060);
    final bg = backgroundColor ?? Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // S Monogram Circle
          Container(
            width: size * 0.4,
            height: size * 0.4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'S',
                style: TextStyle(
                  fontSize: size * 0.25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Brand Name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sahay',
                style: TextStyle(
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (showTagline)
                Text(
                  'LOANS IN MINUTES',
                  style: TextStyle(
                    fontSize: size * 0.1,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 1,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Bilingual Badge Style - Navy square with Devanagari + English
  Widget _buildBilingualBadge() {
    final primary = primaryColor ?? const Color(0xFF1A237E);
    final bg = backgroundColor ?? Colors.white;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Navy Square with Devanagari
          Container(
            width: size * 0.5,
            height: size * 0.5,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'स',
                style: TextStyle(
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Brand Name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sahay',
                style: TextStyle(
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              if (showDevanagari || showTagline)
                Text(
                  showDevanagari ? 'सहाय · MICRO LOANS' : 'MICRO LOANS',
                  style: TextStyle(
                    fontSize: size * 0.1,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Stamp Seal Style - Circular emblem
  Widget _buildStampSeal() {
    final primary = primaryColor ?? const Color(0xFF1A237E);
    final bg = backgroundColor ?? Colors.white;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular Seal
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: primary, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'स',
                style: TextStyle(
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              Text(
                'SAHAY',
                style: TextStyle(
                  fontSize: size * 0.15,
                  fontWeight: FontWeight.bold,
                  color: primary,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        if (showDevanagari) ...[
          const SizedBox(height: 8),
          Text(
            'सहाय • Sahay',
            style: TextStyle(
              fontSize: size * 0.18,
              fontWeight: FontWeight.w600,
              color: primary,
            ),
          ),
        ],
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            'AAPKA VISHWASNEEY LOAN PARTNER',
            style: TextStyle(
              fontSize: size * 0.08,
              color: Colors.grey[600],
              letterSpacing: 1,
            ),
          ),
        ],
      ],
    );
  }

  /// Minimal Style - Simple icon + text
  Widget _buildMinimal() {
    final primary = primaryColor ?? const Color(0xFF1A237E);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size * 0.45,
          height: size * 0.45,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              'स',
              style: TextStyle(
                fontSize: size * 0.3,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SAHAY',
              style: TextStyle(
                fontSize: size * 0.25,
                fontWeight: FontWeight.bold,
                color: primary,
                letterSpacing: 2,
              ),
            ),
            if (showTagline)
              Text(
                'LOANS IN MINUTES',
                style: TextStyle(
                  fontSize: size * 0.08,
                  color: Colors.grey[600],
                  letterSpacing: 1,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

enum SahayLogoStyle {
  pillBadge,      // Emerald pill with S monogram
  bilingualBadge, // Navy square + white badge
  stampSeal,      // Circular postage stamp style
  minimal,        // Simple icon + text
}

/// Small logo widget for app bars and headers
class SahayLogoSmall extends StatelessWidget {
  final Color? color;

  const SahayLogoSmall({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? const Color(0xFF1A237E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: logoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: logoColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Text(
                'स',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'SAHAY',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: logoColor,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
