import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/delivery_type.dart';
import '../services/api_error.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  bool _useChamaDiscount = false;
  String phone = '';
  String deliveryLocation = '';
  String notes = '';
  String? _couponCode;
  double _couponDiscount = 0;
  bool _couponBusy = false;
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

  String? get couponCode => _couponCode;
  double get couponDiscount => _couponDiscount;
  bool get couponBusy => _couponBusy;

  double get discountedSubtotal =>
      (subtotal - chamaSavings - _couponDiscount).clamp(0.0, double.infinity);

  /// Returns null on success, otherwise an error message.
  Future<String?> applyCoupon(String code) async {
    code = code.trim();
    if (code.isEmpty) return 'Enter a promo code';
    if (_items.isEmpty) return 'Your cart is empty';
    _couponBusy = true;
    notifyListeners();
    try {
      final svc = CartService.instance;
      await svc.syncCart([
        for (final i in _items) (productId: i.product.id, qty: i.quantity),
      ]);
      final res = await svc.applyCoupon(code);
      if (res.error) {
        return res.message ?? 'This promo code is invalid or expired';
      }
      final cart = await svc.getCart();
      if (cart.appliedCouponCode == null || cart.couponDiscount <= 0) {
        try {
          await svc.removeCoupon();
        } catch (_) {}
        return 'This promo code gives no discount on your cart';
      }
      _couponCode = cart.appliedCouponCode;
      _couponDiscount = cart.couponDiscount;
      return null;
    } on ApiError catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not apply the promo code. Please try again.';
    } finally {
      _couponBusy = false;
      notifyListeners();
    }
  }

  Future<void> removeCoupon() async {
    try {
      await CartService.instance.removeCoupon();
    } catch (_) {}
    _resetCoupon();
    notifyListeners();
  }

  void _resetCoupon() {
    _couponCode = null;
    _couponDiscount = 0;
  }

  double get deliveryFeeRaw {
    switch (_deliveryType) {
      case DeliveryType.doorstep:
        return 300.0;
      case DeliveryType.schoolGate:
      case DeliveryType.courier:
        return 0.0; // confirmed with the customer on WhatsApp
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
    _resetCoupon();
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
    _resetCoupon();
    if (index < 0 || index >= _items.length) return;
    final item = _items[index];
    _items[index] = item.copyWith(quantity: item.quantity + 1);
    notifyListeners();
  }

  void decrementQuantity(int index) {
    _resetCoupon();
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
    _resetCoupon();
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    _resetCoupon();
    _items.clear();
    notifyListeners();
  }

  void setItemCondition(int index, bool isPreowned) {
    _resetCoupon();
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
