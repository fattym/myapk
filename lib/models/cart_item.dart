import 'package:flutter/foundation.dart';
import 'product.dart';

@immutable
class CartItem {
  final Product product;
  final int quantity;
  final bool isPreowned;
  final double price;

  const CartItem({
    required this.product,
    required this.quantity,
    required this.isPreowned,
    required this.price,
  });

  CartItem copyWith({
    Product? product,
    int? quantity,
    bool? isPreowned,
    double? price,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      isPreowned: isPreowned ?? this.isPreowned,
      price: price ?? this.price,
    );
  }

  double get totalPrice => price * quantity;

  String get conditionLabel => isPreowned ? 'Refurbished' : 'New';
}
