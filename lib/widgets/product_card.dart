import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../utils/formatters.dart';
import '../utils/icons.dart';
import '../theme/colors.dart';

class ProductCard extends StatefulWidget {
  /// Grid cell height that fits the card content for these products.
  static double gridExtent(Iterable<Product> products) {
    final hasToggle = products.any((p) => (p.preOwnedPrice ?? 0) > 0);
    return 262 + (hasToggle ? 44 : 0);
  }

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
    final hasPreowned = widget.product.preOwnedPrice != null && widget.product.preOwnedPrice! > 0;
    final displayPrice = _isPreowned
        ? (widget.product.preOwnedPrice ?? widget.product.newPrice)
        : widget.product.newPrice;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.dividerColor),
      ),
       clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product image (falls back to an icon)
            Container(
              height: 120,
              color: const Color(0xFFF4EEF8),
              child: (widget.product.imageUrl != null &&
                      widget.product.imageUrl!.isNotEmpty)
                  ? Image.network(
                      widget.product.imageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => _iconFallback(),
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                              ? child
                              : const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                    )
                  : _iconFallback(),
            ),
            // Product details (fills available space so the card never overflows
            // its grid cell; texts are single-line and truncate when needed)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Price
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: formatKES(displayPrice),
                            style: const TextStyle(
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          if (!_isPreowned && widget.product.oldPrice != null)
                            TextSpan(
                              text: '  ${widget.product.oldPrice!.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
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
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: SizedBox(
                height: 40,
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
                  child: const Text('Add to cart'),
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _iconFallback() => Icon(
        getIconForName(widget.product.iconName),
        size: 44,
        color: AppColors.primaryPurple,
      );

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
