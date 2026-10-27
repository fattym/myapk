import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/delivery_type.dart';
import '../providers/cart_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/colors.dart';
import '../utils/formatters.dart';
import '../utils/icons.dart';
import '../widgets/modals/mpesa_stk_modal.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        title: Text(
          'My Cart',
          style: theme.textTheme.titleLarge,
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
                  // Chama Group Order Pooling Banner
                  _buildChamaBanner(context, cart),
                  const SizedBox(height: 16),
                  // Cart Items List
                  _buildCartItems(context, cart),
                  const SizedBox(height: 16),
                  // Delivery Selector
                  _buildDeliverySelector(context, cart),
                  const SizedBox(height: 16),
                  // Order Summary
                  _buildOrderSummary(context, cart),
                  const SizedBox(height: 16),
                  // Lipa Polepole Breakdown
                  _buildLipapolepole(context, cart),
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

  Widget _buildChamaBanner(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accentGold, AppColors.goldHover],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FaIcon(
                FontAwesomeIcons.handHoldingHeart,
                color: AppColors.darkPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Chama Group Order Pooling',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.darkPurple,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Apply 10% discount and free school gate delivery',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.darkPurple,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text(
              'Apply Chama Discount',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkPurple,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            value: cart.useChamaDiscount,
            onChanged: (value) => cart.toggleChamaDiscount(value),
            activeThumbColor: AppColors.primaryPurple,
            activeTrackColor: AppColors.lightPurple,
            secondary: const Icon(
              Icons.local_offer,
              color: AppColors.darkPurple,
            ),
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
                        Icon(
                          getIconForName(item.product.iconName),
                          color: AppColors.primaryPurple,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
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
                  subtitle: Text(
                    type.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  trailing: Text(
                    isFree ? 'FREE' : type.priceLabel,
                    style: TextStyle(
                      color: isFree ? Colors.green[600] : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
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
          _buildSummaryRow('Delivery Fee', formatKES(cart.deliveryFee)),
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

  Widget _buildLipapolepole(BuildContext context, CartProvider cart) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGold,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Lipa Polepole (3 Installments)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.darkPurple,
            ),
          ),
          const SizedBox(height: 12),
          _buildPaymentRow(
            'Deposit (33%)',
            formatKES(cart.deposit),
            'Due today',
          ),
          _buildPaymentRow(
            'Term 1 Payment',
            formatKES(cart.termPayment),
            'In 1 month',
          ),
          _buildPaymentRow(
            'Term 2 Payment',
            formatKES(cart.termPayment),
            'In 2 months',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String amount, String dueDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.darkPurple,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                dueDate,
                style: const TextStyle(
                  color: AppColors.darkPurple,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          Text(
            amount,
            style: const TextStyle(
              color: AppColors.darkPurple,
              fontWeight: FontWeight.w700,
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
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => MpesaStkModal(totalAmount: cart.total),
            );
          },
          icon: const FaIcon(
            FontAwesomeIcons.mobileScreenButton,
            size: 18,
          ),
          label: const Text('Pay via M-Pesa STK Push'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            foregroundColor: AppColors.surfaceWhite,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _openWhatsApp(context, cart),
          icon: const FaIcon(
            FontAwesomeIcons.whatsapp,
            size: 18,
          ),
          label: const Text('Order via WhatsApp'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D36F),
            foregroundColor: AppColors.surfaceWhite,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openWhatsApp(BuildContext context, CartProvider cart) async {
    final profileProvider = context.read<ProfileProvider>();
    final buffer = StringBuffer();
    buffer.writeln('MyBidhaa Order Summary');
    buffer.writeln('');
    for (final item in cart.items) {
      final condition = item.isPreowned ? ' (Refurbished)' : '';
      buffer.writeln(
        '${item.product.title}$condition x${item.quantity} = ${formatKES(item.totalPrice)}',
      );
    }
    buffer.writeln('');
    buffer.writeln('Subtotal: ${formatKES(cart.subtotal)}');
    if (cart.useChamaDiscount) {
      buffer.writeln('Chama Discount: -${formatKES(cart.chamaSavings)}');
    }
    buffer.writeln('Delivery: ${cart.deliveryType.label}');
    if (cart.deliveryFee > 0) {
      buffer.writeln('Delivery Fee: ${formatKES(cart.deliveryFee)}');
    } else {
      buffer.writeln('Delivery Fee: FREE');
    }
    buffer.writeln('');
    buffer.writeln('TOTAL: ${formatKES(cart.total)}');
    buffer.writeln('');
    buffer.writeln('Student: ${profileProvider.selectedProfile.displayName}');
    buffer.writeln('');
    buffer.writeln('I would like to place this order. Please confirm.');

    final encoded = Uri.encodeComponent(buffer.toString());
    final url = 'https://wa.me/254797100500?text=$encoded';
    await launchUrl(Uri.parse(url));
  }
}
