import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../screens/cart_screen.dart';
import '../theme/colors.dart';

/// Cart button with item-count badge (opens the cart screen).
class CartButton extends StatelessWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.watch<CartProvider>().totalCartItems;
    return Semantics(
      button: true,
      label: 'Cart, $count items',
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CartScreen()),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: const Icon(Icons.shopping_cart_outlined,
                  color: AppColors.primaryPurple, size: 22),
            ),
            if (count > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  constraints:
                      const BoxConstraints(minWidth: 18, minHeight: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: AppColors.darkPurple,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Screen title block with an optional subtitle and the cart button.
class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showCart;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showCart = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showCart) ...[
              const SizedBox(width: 12),
              const CartButton(),
            ],
          ],
        ),
      ),
    );
  }
}

/// Rounded search field used on Home, Categories and Catalog.
class AppSearchField extends StatefulWidget {
  final String hint;
  final String initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const AppSearchField({
    super.key,
    required this.hint,
    this.initialValue = '',
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon:
            const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.primaryPurple, width: 2),
        ),
      ),
    );
  }
}
