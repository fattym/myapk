import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../utils/formatters.dart';
import '../utils/icons.dart';
import '../theme/colors.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final bool showConditionToggle;
  final Function(Product)? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.showConditionToggle = true,
    this.onAddToCart,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isPreowned = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPreowned = widget.product.preOwnedPrice != null && widget.product.preOwnedPrice! > 0;
    final displayPrice = _isPreowned
        ? (widget.product.preOwnedPrice ?? widget.product.newPrice)
        : widget.product.newPrice;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
       clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product icon
            Container(
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFF4EEF8),
              ),
              child: Icon(
                getIconForName(widget.product.iconName),
                size: 48,
                color: AppColors.primaryPurple,
              ),
            ),
            // Product details (fills available space so the card never overflows
            // its grid cell; texts are single-line and truncate when needed)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.product.category} \u2022 ${widget.product.publisher}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Grade: ${widget.product.grade}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Price
                    Text(
                      formatKES(displayPrice),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Condition toggle
                    if (hasPreowned && widget.showConditionToggle)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            _buildConditionButton('New', !_isPreowned),
                            const SizedBox(width: 8),
                            _buildConditionButton('Refurbished', _isPreowned),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Add to Cart button
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: () {
                    final cart = context.read<CartProvider>();
                    cart.addItem(widget.product, isPreowned: _isPreowned);
                    if (widget.onAddToCart != null) {
                      widget.onAddToCart!(widget.product);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${widget.product.title} added to cart'),
                        backgroundColor: AppColors.primaryPurple,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Text('Add to Cart'),
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildConditionButton(String label, bool selected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isPreowned = label == 'Refurbished';
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? AppColors.primaryPurple
                  : AppColors.primaryPurple.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.primaryPurple,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
