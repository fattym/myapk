import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/catalog_provider.dart';
import '../theme/colors.dart';
import '../widgets/app_header.dart';
import '../widgets/product_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients &&
          _scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
        context.read<CatalogProvider>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _sync(AppProvider app, CatalogProvider catalog) {
    // Run after build: filters changed in the app bar / categories / home.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      catalog.setFilters(
        query: app.searchQuery,
        categoryId: app.selectedCategoryId,
        brandId: app.selectedBrandId,
        categoryName: app.selectedCategory,
        brandName: app.selectedPublisher,
        discountedOnly: app.discountedOnly,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = context.watch<AppProvider>();
    final catalog = context.watch<CatalogProvider>();
    _sync(app, catalog);

    final products = catalog.products;
    Widget body;
    if (catalog.status == CatalogStatus.loading && products.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (products.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, color: Colors.grey[400], size: 64),
              const SizedBox(height: 16),
              Text(
                catalog.status == CatalogStatus.error
                    ? (catalog.error ?? 'Could not load products')
                    : 'No products found',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              if (catalog.status == CatalogStatus.error)
                TextButton.icon(
                  onPressed: catalog.retry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                )
              else
                Text(
                  'Try adjusting your search or filter',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.grey[500]),
                ),
            ],
          ),
        ),
      );
    } else {
      body = GridView.builder(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: ProductCard.gridExtent(products),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: products.length + (catalog.loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= products.length) {
            return const Center(child: CircularProgressIndicator());
          }
          return ProductCard(product: products[index]);
        },
      );
    }

    final hasFilters = app.discountedOnly ||
        app.selectedCategory != null ||
        app.selectedPublisher != null ||
        app.searchQuery.isNotEmpty;
    final countText = catalog.status == CatalogStatus.loading
        ? 'Loading...'
        : hasFilters
            ? '${catalog.total} results${app.searchQuery.isNotEmpty ? ' for "${app.searchQuery}"' : ''}'
            : '${catalog.total} products';

    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenHeader(title: 'Catalog'),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: AppSearchField(
              hint: 'Search books, stationery...',
              initialValue: app.searchQuery,
              onChanged: (v) => context.read<AppProvider>().setSearchQuery(v),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                if (app.discountedOnly)
                  _filterChip(
                    'On discount',
                    selected: true,
                    onDeleted: () =>
                        context.read<AppProvider>().setDiscountedOnly(false),
                  )
                else
                  _filterChip(
                    'On discount',
                    onTap: () =>
                        context.read<AppProvider>().setDiscountedOnly(true),
                  ),
                if (app.selectedCategory != null)
                  _filterChip(
                    app.selectedCategory!,
                    selected: true,
                    onDeleted: () =>
                        context.read<AppProvider>().setSelectedCategory(null),
                  ),
                if (app.selectedPublisher != null)
                  _filterChip(
                    app.selectedPublisher!,
                    selected: true,
                    onDeleted: () =>
                        context.read<AppProvider>().setSelectedPublisher(null),
                  )
                else
                  _filterChip(
                    'Publisher',
                    onTap: () => _pickPublisher(context),
                  ),
                if (app.selectedCategory == null)
                  _filterChip(
                    'Category',
                    onTap: () => _pickCategory(context),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    countText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                if (catalog.usingSample)
                  const Tooltip(
                    message: 'Showing offline sample data',
                    child: Icon(Icons.cloud_off, size: 18, color: Colors.grey),
                  ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _filterChip(String label,
      {bool selected = false, VoidCallback? onTap, VoidCallback? onDeleted}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InputChip(
        label: onTap != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down,
                      size: 18, color: AppColors.textSecondary),
                ],
              )
            : Text(label),
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? Colors.white : AppColors.textPrimary,
        ),
        backgroundColor: selected ? AppColors.primaryPurple : Colors.white,
        side: BorderSide(
          color: selected ? AppColors.primaryPurple : AppColors.dividerColor,
        ),
        shape: const StadiumBorder(),
        deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
        onDeleted: onDeleted,
        onPressed: onTap,
      ),
    );
  }

  Future<void> _pickPublisher(BuildContext context) async {
    final catalog = context.read<CatalogProvider>();
    await catalog.loadBrands();
    if (!context.mounted) return;
    final app = context.read<AppProvider>();
    final items = catalog.publishers;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheet) => ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text('Publisher',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ),
          for (final p in items)
            ListTile(
              title: Text(p.name),
              onTap: () {
                app.setSelectedPublisher(p.name, id: p.id);
                Navigator.of(sheet).pop();
              },
            ),
        ],
      ),
    );
  }

  Future<void> _pickCategory(BuildContext context) async {
    final catalog = context.read<CatalogProvider>();
    await catalog.loadCategories();
    if (!context.mounted) return;
    final app = context.read<AppProvider>();
    final items = catalog.departments;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheet) => ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text('Category',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ),
          for (final d in items)
            ListTile(
              title: Text(d.name),
              onTap: () {
                app.setSelectedCategory(d.name, id: catalog.categoryIdFor(d));
                Navigator.of(sheet).pop();
              },
            ),
        ],
      ),
    );
  }
}
