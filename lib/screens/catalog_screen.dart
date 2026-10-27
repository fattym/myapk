import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/products.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../providers/app_provider.dart';
import '../theme/colors.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  List<Product> _getFilteredProducts(AppProvider appProvider) {
    return sampleProducts.where((product) {
      if (appProvider.selectedCategory != null &&
          product.category != appProvider.selectedCategory) {
        return false;
      }
      if (appProvider.selectedPublisher != null &&
          product.publisher != appProvider.selectedPublisher) {
        return false;
      }
      if (appProvider.searchQuery.isNotEmpty &&
          !product.title
              .toLowerCase()
              .contains(appProvider.searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final products = _getFilteredProducts(appProvider);

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    color: Colors.grey[400],
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products found',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search or filter',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  appProvider.selectedCategory ??
                  appProvider.selectedPublisher ??
                  (appProvider.searchQuery.isNotEmpty
                      ? 'Search results for "${appProvider.searchQuery}"'
                      : 'All Products'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: products[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
