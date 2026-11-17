import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/delivery_type.dart';
import '../providers/cart_provider.dart';
import '../theme/colors.dart';
import '../utils/formatters.dart';
import '../utils/icons.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        title: const Text(
          'My cart',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              if (!cart.hasItems) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => cart.clearCart(),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: Colors.red[400],
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (!cart.hasItems) {
            return _buildEmptyState(context);
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cart Items List
                  _buildCartItems(context, cart),
                  const SizedBox(height: 16),
                  // Delivery Selector
                  _buildDeliverySelector(context, cart),
                  const SizedBox(height: 16),
                  const _OrderDetailsForm(),
                  const SizedBox(height: 16),
                  // Order Summary
                  _buildOrderSummary(context, cart),
                  const SizedBox(height: 16),
                  // Checkout Buttons
                  _buildCheckoutButtons(context, cart),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart,
            color: Colors.grey[300],
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(BuildContext context, CartProvider cart) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items in Cart (${cart.items.length})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cart.items.length,
          itemBuilder: (context, index) {
            final item = cart.items[index];
            final hasPreowned = item.product.preOwnedPrice != null &&
                item.product.preOwnedPrice! > 0;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Top row: icon, title, price
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: item.product.imageUrl == null
                                ? Icon(
                                    getIconForName(item.product.iconName),
                                    color: AppColors.primaryPurple,
                                    size: 28,
                                  )
                                : Image.network(
                                    item.product.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Icon(
                                      getIconForName(item.product.iconName),
                                      color: AppColors.primaryPurple,
                                      size: 28,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.title,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${item.product.category} \u2022 ${item.product.publisher}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item.conditionLabel,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.primaryPurple,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'x${item.quantity}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              formatKES(item.totalPrice),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.primaryPurple,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Bottom row: condition toggle, quantity, remove
                    Row(
                      children: [
                        // Condition toggle
                        if (hasPreowned)
                          Row(
                            children: [
                              _buildConditionChip(
                                'New',
                                !item.isPreowned,
                                () => cart.setItemCondition(index, false),
                                theme,
                              ),
                              const SizedBox(width: 4),
                              _buildConditionChip(
                                'Refurbished',
                                item.isPreowned,
                                () => cart.setItemCondition(index, true),
                                theme,
                              ),
                            ],
                          ),
                        const Spacer(),
                        // Quantity controls
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.subtlePurple,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.remove,
                                  color: AppColors.primaryPurple,
                                  size: 18,
                                ),
                                onPressed: () =>
                                    cart.decrementQuantity(index),
                              ),
                              Text(
                                item.quantity.toString(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.add,
                                  color: AppColors.primaryPurple,
                                  size: 18,
                                ),
                                onPressed: () => cart.incrementQuantity(index),
                              ),
                            ],
                          ),
                        ),
                        // Remove button
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red[400],
                            size: 20,
                          ),
                          onPressed: () => cart.removeItem(index),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildConditionChip(
    String label,
    bool selected,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected
                ? AppColors.primaryPurple
                : AppColors.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDeliverySelector(BuildContext context, CartProvider cart) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Method',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          RadioGroup<DeliveryType>(
            groupValue: cart.deliveryType,
            onChanged: (DeliveryType? value) {
              if (value != null) {
                cart.setDeliveryType(value);
              }
            },
            child: Column(
              children: DeliveryType.values.map((type) {
                final isSelected = cart.deliveryType == type;
                final isFree =
                    cart.isDeliveryFree && type == DeliveryType.schoolGate;
                return ListTile(
                  leading: Radio<DeliveryType>(value: type),
                  selected: isSelected,
                  title: Text(
                    type.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      if (type.priceLabel.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        isFree ? 'FREE' : type.priceLabel,
                        style: TextStyle(
                          color: isFree
                              ? Colors.green[600]
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartProvider cart) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.subtlePurple.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Order Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Subtotal', formatKES(cart.subtotal)),
          if (cart.useChamaDiscount)
            _buildSummaryRow(
              'Chama Savings (10%)',
              '-${formatKES(cart.chamaSavings)}',
              isNegative: true,
            ),
          if (cart.couponCode != null)
            _buildSummaryRow(
              'Promo (${cart.couponCode})',
              '-${formatKES(cart.couponDiscount)}',
              isNegative: true,
            ),
          _buildSummaryRow(
              'Delivery Fee',
              cart.deliveryType == DeliveryType.doorstep
                  ? formatKES(cart.deliveryFee)
                  : 'Confirmed on WhatsApp'),
          const SizedBox(height: 8),
          const _PromoCodeField(),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _buildSummaryRow('Total', formatKES(cart.total), isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String amount, {
    bool isTotal = false,
    bool isNegative = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,
              color: isNegative
                  ? Colors.red[600]
                  : isTotal
                      ? AppColors.primaryPurple
                      : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButtons(BuildContext context, CartProvider cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => _openWhatsApp(context, cart),
          icon: const FaIcon(
            FontAwesomeIcons.whatsapp,
            size: 18,
          ),
          label: const Text('Checkout with WhatsApp'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF147A3F),
            foregroundColor: AppColors.surfaceWhite,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: null,
          icon: const FaIcon(
            FontAwesomeIcons.mobileScreenButton,
            size: 18,
          ),
          label: const Text('Pay with M-Pesa (coming soon)'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openWhatsApp(BuildContext context, CartProvider cart) async {
    if (cart.phone.trim().isEmpty || cart.deliveryLocation.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please add your phone number and delivery location.'),
      ));
      return;
    }
    final buffer = StringBuffer();
    buffer.writeln('MyBidhaa Order Summary');
    buffer.writeln('');
    for (final item in cart.items) {
      final condition = item.isPreowned ? ' (Refurbished)' : '';
      buffer.writeln(
        '${item.product.title}$condition x${item.quantity} = ${formatKES(item.totalPrice)}',
      );
      final img = item.product.imageUrl;
      if (img != null && img.isNotEmpty) buffer.writeln('Image: $img');
      final slug = item.product.slug;
      if (slug != null && slug.isNotEmpty) {
        buffer.writeln('Link: https://mybidhaa.com/products/$slug');
      }
      buffer.writeln('');
    }
    buffer.writeln('');
    buffer.writeln('Subtotal: ${formatKES(cart.subtotal)}');
    if (cart.useChamaDiscount) {
      buffer.writeln('Chama Discount: -${formatKES(cart.chamaSavings)}');
    }
    if (cart.couponCode != null) {
      buffer.writeln(
          'Promo (${cart.couponCode}): -${formatKES(cart.couponDiscount)}');
    }
    buffer.writeln('Delivery: ${cart.deliveryType.label}');
    if (cart.deliveryType == DeliveryType.doorstep) {
      buffer.writeln('Delivery Fee: ${formatKES(cart.deliveryFee)}');
    } else {
      buffer.writeln('Delivery Fee: to be confirmed');
    }
    buffer.writeln('');
    buffer.writeln('Phone: ${cart.phone.trim()}');
    buffer.writeln('Delivery location: ${cart.deliveryLocation.trim()}');
    if (cart.notes.trim().isNotEmpty) {
      buffer.writeln('More details: ${cart.notes.trim()}');
    }
    buffer.writeln('');
    buffer.writeln('TOTAL: ${formatKES(cart.total)}');
    buffer.writeln('');
    buffer.writeln('I would like to place this order. Please confirm.');

    final encoded = Uri.encodeComponent(buffer.toString());
    final url = 'https://wa.me/254797100500?text=$encoded';
    await launchUrl(Uri.parse(url));
  }
}


class _PromoCodeField extends StatefulWidget {
  const _PromoCodeField();

  @override
  State<_PromoCodeField> createState() => _PromoCodeFieldState();
}

class _PromoCodeFieldState extends State<_PromoCodeField> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _apply(CartProvider cart) async {
    final err = await cart.applyCoupon(_controller.text);
    if (!mounted) return;
    setState(() => _error = err);
    if (err == null) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    if (cart.couponCode != null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: cart.removeCoupon,
          icon: const Icon(Icons.close, size: 16),
          label: Text('Remove promo ${cart.couponCode}'),
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            onSubmitted: (_) => _apply(cart),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Promo code',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: cart.couponBusy ? null : () => _apply(cart),
          child: cart.couponBusy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Apply'),
        ),
      ],
    );
  }
}


class _OrderDetailsForm extends StatefulWidget {
  const _OrderDetailsForm();

  @override
  State<_OrderDetailsForm> createState() => _OrderDetailsFormState();
}

class _OrderDetailsFormState extends State<_OrderDetailsForm> {
  late final TextEditingController _phone;
  late final TextEditingController _location;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final cart = context.read<CartProvider>();
    _phone = TextEditingController(text: cart.phone);
    _location = TextEditingController(text: cart.deliveryLocation);
    _notes = TextEditingController(text: cart.notes);
  }

  @override
  void dispose() {
    _phone.dispose();
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order details',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          onChanged: (v) => cart.phone = v,
          decoration: const InputDecoration(
              labelText: 'Phone number *', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _location,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (v) => cart.deliveryLocation = v,
          decoration: const InputDecoration(
              labelText: 'Delivery location *',
              hintText: 'Estate / road / school',
              border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _notes,
          minLines: 2,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (v) => cart.notes = v,
          decoration: const InputDecoration(
              labelText: 'More details (optional)',
              alignLabelWithHint: true,
              border: OutlineInputBorder()),
        ),
      ],
    );
  }
}
