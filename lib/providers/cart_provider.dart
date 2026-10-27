import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/delivery_type.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  bool _useChamaDiscount = false;
  DeliveryType _deliveryType = DeliveryType.doorstep;

  List<CartItem> get items => List.unmodifiable(_items);
  int get totalCartItems => _items.fold(0, (sum, item) => sum + item.quantity);
  int get uniqueItemCount => _items.length;
  bool get useChamaDiscount => _useChamaDiscount;
  DeliveryType get deliveryType => _deliveryType;

  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get chamaDiscountPercent => 0.10;

  double get chamaSavings =>
      _useChamaDiscount ? (subtotal * chamaDiscountPercent) : 0.0;

  double get discountedSubtotal => subtotal - chamaSavings;

  double get deliveryFeeRaw {
    switch (_deliveryType) {
      case DeliveryType.doorstep:
        return 250.0;
      case DeliveryType.schoolGate:
        return _useChamaDiscount ? 0.0 : 100.0;
      case DeliveryType.courier:
        return 180.0;
    }
  }

  double get deliveryFee => deliveryFeeRaw;

  double get total => discountedSubtotal + deliveryFee;

  bool get isDeliveryFree {
    if (_deliveryType == DeliveryType.schoolGate && _useChamaDiscount) {
      return true;
    }
    return false;
  }

  bool get hasItems => _items.isNotEmpty;

  double get deposit => total * 0.33;
  double get remainingAfterDeposit => total - deposit;
  double get termPayment => remainingAfterDeposit / 2;

  void addItem(Product product, {bool isPreowned = false, int quantity = 1}) {
    final existingIndex = _items.indexWhere(
      (item) =>
          item.product.id == product.id && item.isPreowned == isPreowned,
    );
    if (existingIndex != -1) {
      final existing = _items[existingIndex];
      _items[existingIndex] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    } else {
      final price = isPreowned
          ? (product.preOwnedPrice ?? product.newPrice)
          : product.newPrice;
      _items.add(CartItem(
        product: product,
        quantity: quantity,
        isPreowned: isPreowned,
        price: price,
      ));
    }
    notifyListeners();
  }

  void incrementQuantity(int index) {
    if (index < 0 || index >= _items.length) return;
    final item = _items[index];
    _items[index] = item.copyWith(quantity: item.quantity + 1);
    notifyListeners();
  }

  void decrementQuantity(int index) {
    if (index < 0 || index >= _items.length) return;
    final item = _items[index];
    if (item.quantity > 1) {
      _items[index] = item.copyWith(quantity: item.quantity - 1);
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void removeItem(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void setItemCondition(int index, bool isPreowned) {
    if (index < 0 || index >= _items.length) return;
    final item = _items[index];
    final price = isPreowned
        ? (item.product.preOwnedPrice ?? item.product.newPrice)
        : item.product.newPrice;
    _items[index] = item.copyWith(
      isPreowned: isPreowned,
      price: price,
    );
    notifyListeners();
  }

  void toggleChamaDiscount(bool value) {
    _useChamaDiscount = value;
    notifyListeners();
  }

  void setDeliveryType(DeliveryType type) {
    _deliveryType = type;
    notifyListeners();
  }

  void setConditionForProduct(Product product, bool isPreowned) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      final item = _items[index];
      final price = isPreowned
          ? (product.preOwnedPrice ?? product.newPrice)
          : product.newPrice;
      _items[index] = item.copyWith(
        isPreowned: isPreowned,
        price: price,
      );
      notifyListeners();
    }
  }
}
