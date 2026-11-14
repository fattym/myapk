import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../providers/catalog_provider.dart';
import '../theme/colors.dart';
import '../widgets/app_header.dart';
import '../widgets/hero_banner.dart';
import '../widgets/product_card.dart';
import '../widgets/sell_trade_in_card.dart';

class HomeScreen extends StatefulWidget {
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

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = context.read<CatalogProvider>();
      c.loadCategories();
      c.loadFeatured();
    });
  }

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse(
      'https://wa.me/254797100500?text=${Uri.encodeComponent("Hi MyBidhaa, I would like to shop via WhatsApp.")}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _sectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                'See all',
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, Color color,
      VoidCallback? onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.dividerColor),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final departments = catalog.departments;
    final featured = catalog.featured;

    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.menu_book,
                          color: AppColors.accentGold, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'MyBidhaa',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryPurple,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const CartButton(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: AppSearchField(
                hint: 'Search books, stationery, uniforms',
                onSubmitted: (q) {
                  context.read<AppProvider>()
                    ..clearFilters()
                    ..setSearchQuery(q);
                  widget.onNavigateToTab?.call(2);
                },
              ),
            ),
            HeroBanner(
              onScanTap: widget.onScanTap,
              onSearchSchoolTap: widget.onSearchSchoolTap,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  _quickAction(Icons.document_scanner_outlined, 'Scan list',
                      AppColors.primaryPurple, widget.onScanTap),
                  const SizedBox(width: 10),
                  _quickAction(Icons.school_outlined, 'Schools',
                      AppColors.primaryPurple, widget.onSearchSchoolTap),
                  const SizedBox(width: 10),
                  _quickAction(Icons.chat_outlined, 'WhatsApp',
                      const Color(0xFF147A3F), _openWhatsApp),
                ],
              ),
            ),
            _sectionHeader('Shop by category',
                onSeeAll: () => widget.onNavigateToTab?.call(1)),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: departments.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final d = departments[i];
                  return ActionChip(
                    label: Text(d.name),
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.dividerColor),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    onPressed: () {
                      context.read<AppProvider>().setSelectedCategory(
                            d.name,
                            id: catalog.categoryIdFor(d),
                          );
                      widget.onNavigateToTab?.call(2);
                    },
                  );
                },
              ),
            ),
            _sectionHeader('Recommended for you',
                onSeeAll: () => widget.onNavigateToTab?.call(2)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: ProductCard.gridExtent(featured),
                ),
                itemCount: featured.length,
                itemBuilder: (context, i) => ProductCard(product: featured[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SellTradeInCard(onTap: widget.onTradeInTap),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
