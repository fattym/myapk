import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/products.dart';
import '../data/departments.dart';
import '../data/publishers.dart';
import '../providers/app_provider.dart';
import '../theme/colors.dart';
import '../widgets/hero_banner.dart';
import '../widgets/product_card.dart';
import '../widgets/department_card.dart';
import '../widgets/publisher_card.dart';
import '../widgets/sell_trade_in_card.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onScanTap;
  final VoidCallback? onSearchSchoolTap;
  final Function(int)? onNavigateToTab;
  final VoidCallback? onTradeInTap;

  const HomeScreen({
    super.key,
    this.onScanTap,
    this.onSearchSchoolTap,
    this.onNavigateToTab,
    this.onTradeInTap,
  });

  Widget _buildSectionHeader(BuildContext context, String title,
      {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                'See All',
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Hero Banner
            HeroBanner(
              onScanTap: onScanTap,
              onSearchSchoolTap: onSearchSchoolTap,
            ),
            const SizedBox(height: 8),
            // KICD Approved Publishers
            _buildSectionHeader(context, 'KICD Approved Publishers'),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: samplePublishers.length,
                  itemBuilder: (context, index) {
                    return PublisherCard(
                      publisher: samplePublishers[index],
                      onTap: () {
                        context
                            .read<AppProvider>()
                            .setSelectedPublisher(samplePublishers[index].name);
                        onNavigateToTab?.call(2);
                      },
                    );
                  },
                ),
              ),
            ),
            // Department Quick Access
            _buildSectionHeader(
              context,
              'Shop by Department',
              onSeeAll: () => onNavigateToTab?.call(1),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 160,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: sampleDepartments.length,
                itemBuilder: (context, index) {
                  return DepartmentCard(
                    department: sampleDepartments[index],
                    onTap: () {
                      context
                          .read<AppProvider>()
                          .setSelectedCategory(sampleDepartments[index].name);
                      onNavigateToTab?.call(2);
                    },
                  );
                },
              ),
            ),
            // Recommended for You
            _buildSectionHeader(
              context,
              'Recommended for You',
              onSeeAll: () => onNavigateToTab?.call(2),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const double minTileWidth = 200;
                  const double crossAxisSpacing = 12;
                  final int crossAxisCount = ((constraints.maxWidth + crossAxisSpacing) ~/
                          (minTileWidth + crossAxisSpacing))
                      .clamp(1, 4);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: crossAxisSpacing,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: sampleProducts.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: sampleProducts[index]);
                    },
                  );
                },
              ),
            ),
            // Trade-In Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SellTradeInCard(onTap: onTradeInTap),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
