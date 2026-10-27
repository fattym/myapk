import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/colors.dart';

class HeroBanner extends StatelessWidget {
  final VoidCallback? onScanTap;
  final VoidCallback? onSearchSchoolTap;

  const HeroBanner({
    super.key,
    this.onScanTap,
    this.onSearchSchoolTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkPurple, AppColors.primaryPurple, AppColors.lightPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified,
                      color: AppColors.darkPurple,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'CBC Approved 2026',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.darkPurple,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightGold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: AppColors.darkPurple,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Chama Group 10% Off',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.darkPurple,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Get up to 10% off\nwhen you order with\nyour Chama Group!',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.surfaceWhite,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onScanTap,
                  icon: const FaIcon(FontAwesomeIcons.camera, size: 16),
                  label: const Text('Scan Booklist Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: AppColors.darkPurple,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onSearchSchoolTap,
                  icon: const Icon(Icons.search, size: 16),
                  label: const Text('Search School Directory'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceWhite.withValues(alpha: 0.2),
                    foregroundColor: AppColors.surfaceWhite,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
