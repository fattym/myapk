import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../providers/catalog_provider.dart';
import '../providers/schools_provider.dart';
import '../theme/colors.dart';
import '../utils/category_picker.dart';
import 'account_screen.dart';
import 'services_screen.dart';
import '../widgets/app_header.dart';
import '../widgets/hero_banner.dart';
import '../widgets/product_card.dart';
import '../widgets/brand_logo.dart';
import '../widgets/home_slider.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onScanTap;
  final VoidCallback? onUploadTap;
  final VoidCallback? onSearchSchoolTap;
  final Function(int)? onNavigateToTab;

  const HomeScreen({
    super.key,
    this.onScanTap,
    this.onUploadTap,
    this.onSearchSchoolTap,
    this.onNavigateToTab,
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
      c.loadBrands();
      c.loadFeatured();
      c.loadDeals();
      c.loadSliders();
      context.read<SchoolsProvider>().loadSchools();
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
    final departments = catalog.topDepartments;
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
                    const Expanded(child: Align(alignment: Alignment.centerLeft, child: BrandLogo())),
                    IconButton(
                      tooltip: 'Account',
                      icon: const Icon(Icons.person_outline),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const AccountScreen()),
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
            HomeSlider(onTap: () => widget.onNavigateToTab?.call(2)),
            const SizedBox(height: 16),
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
                  _quickAction(Icons.upload_file_outlined, 'Upload list',
                      AppColors.primaryPurple, widget.onUploadTap),
                  const SizedBox(width: 10),
                  _quickAction(Icons.chat_outlined, 'WhatsApp',
                      const Color(0xFF147A3F), _openWhatsApp),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ServicesScreen())),
                icon: const Icon(Icons.apps),
                label: const Text('Other services'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            if (catalog.deals.isNotEmpty) ...[
              _sectionHeader('Deals & discounts', onSeeAll: () {
                context.read<AppProvider>()
                  ..clearFilters()
                  ..setDiscountedOnly(true);
                widget.onNavigateToTab?.call(2);
              }),
              SizedBox(
                height: ProductCard.gridExtent(catalog.deals),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: catalog.deals.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, i) => SizedBox(
                    width: 168,
                    child: ProductCard(product: catalog.deals[i]),
                  ),
                ),
              ),
            ],
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
                    onPressed: () => openCategory(context, d,
                        () => widget.onNavigateToTab?.call(2)),
                  );
                },
              ),
            ),
            if (catalog.featuredBrands.isNotEmpty) ...[
              _sectionHeader('Featured brands'),
              SizedBox(
                height: 92,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: catalog.featuredBrands.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final b = catalog.featuredBrands[i];
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        context
                            .read<AppProvider>()
                            .setSelectedPublisher(b.name, id: b.id);
                        widget.onNavigateToTab?.call(2);
                      },
                      child: Container(
                        width: 110,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.dividerColor),
                        ),
                        child: b.logoUrl == null
                            ? Center(
                                child: Text(b.name,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis))
                            : Image.network(b.logoUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => Center(
                                    child: Text(b.name,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis))),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
            _sectionHeader('Recommended for you',
                onSeeAll: () => widget.onNavigateToTab?.call(2)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: ProductCard.gridDelegate(context, featured),
                itemCount: featured.length,
                itemBuilder: (context, i) => ProductCard(product: featured[i]),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
