import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../utils/brand.dart';

/// The MyBidhaa logo from the website, with a text fallback while offline.
class BrandLogo extends StatelessWidget {
  final double height;
  const BrandLogo({super.key, this.height = 34});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      Brand.logoUrl,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => _fallback(),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : SizedBox(height: height, width: height * 3),
    );
  }

  Widget _fallback() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: height,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book,
                color: AppColors.accentGold, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'MyBidhaa',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryPurple,
              letterSpacing: -0.3,
            ),
          ),
        ],
      );
}
