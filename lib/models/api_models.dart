import 'package:flutter/foundation.dart';

class PaginatedList<T> {
  PaginatedList({
    required this.data,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  final List<T> data;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  factory PaginatedList.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final dataList = json['data'];
    final List<T> items;
    if (dataList is List) {
      items = dataList
          .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else {
      items = <T>[];
    }
    final meta = Map<String, dynamic>.from(
      (json['meta'] ?? const {}) as Map,
    );
    return PaginatedList<T>(
      data: items,
      currentPage: meta['current_page'] as int? ?? 1,
      perPage: meta['per_page'] as int? ?? items.length,
      total: meta['total'] as int? ?? items.length,
      lastPage: meta['last_page'] as int? ?? 1,
    );
  }

  bool get isLastPage => currentPage >= lastPage;
}

@immutable
final class AuthResult {
  const AuthResult({
    required this.token,
    required this.tokenType,
    this.expiresIn,
    required this.user,
  });

  final String token;
  final String tokenType;
  final int? expiresIn;
  final UserProfile user;

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    final userMap = json['customer'] ?? json['user'] ?? {};
    return AuthResult(
      token: (json['token'] ?? json['access_token'] ?? '') as String,
      tokenType: (json['token_type'] ?? 'Bearer') as String,
      expiresIn: json['expires_in'] as int?,
      user: UserProfile.fromJson(
        Map<String, dynamic>.from(userMap as Map),
      ),
    );
  }
}

@immutable
final class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.createdAt,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? createdAt;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as int? ?? 0,
        name: (json['name'] ?? '') as String,
        email: (json['email'] ?? '') as String,
        phone: json['phone'] as String?,
        createdAt: json['created_at'] as String?,
      );

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
    };
    if (phone != null) json['phone'] = phone;
    if (createdAt != null) json['created_at'] = createdAt;
    return json;
  }
}

@immutable
final class ApiSchool {
  const ApiSchool({
    required this.id,
    required this.name,
    required this.slug,
    required this.location,
    this.contact,
    this.logo,
  });

  final int id;
  final String name;
  final String slug;
  final String location;
  final String? contact;
  final String? logo;

  String get logoUrl => logo == null
      ? ''
      : (logo!.startsWith('http') ? logo! : 'storage/$logo');

  factory ApiSchool.fromJson(Map<String, dynamic> json) => ApiSchool(
        id: json['id'] as int? ?? 0,
        name: (json['name'] ?? '') as String,
        slug: (json['slug'] ?? '') as String,
        location: (json['location'] ?? '') as String,
        contact: json['contact'] as String?,
        logo: json['logo'] as String?,
      );
}

@immutable
final class BooklistProduct {
  const BooklistProduct({
    required this.id,
    required this.name,
    required this.price,
    this.salePrice,
    required this.quantity,
    this.image,
  });

  final int id;
  final String name;
  final double price;
  final double? salePrice;
  final int quantity;
  final String? image;

  double get effectivePrice => salePrice ?? price;

  factory BooklistProduct.fromJson(Map<String, dynamic> json) =>
      BooklistProduct(
        id: json['id'] as int? ?? 0,
        name: (json['name'] ?? '') as String,
        price: _toDouble(json['price']),
        salePrice:
            json['sale_price'] == null ? null : _toDouble(json['sale_price']),
        quantity: json['quantity'] as int? ?? 0,
        image: json['image'] as String?,
      );
}

@immutable
final class GradeBooklist {
  const GradeBooklist({
    required this.id,
    required this.name,
    required this.products,
  });

  final int id;
  final String name;
  final List<BooklistProduct> products;

  factory GradeBooklist.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'] as List? ?? [];
    return GradeBooklist(
      id: json['id'] as int? ?? 0,
      name: (json['name'] ?? '') as String,
      products: rawProducts
          .map((e) => BooklistProduct.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

@immutable
final class SchoolBooklist {
  const SchoolBooklist({required this.school, required this.grades});

  final ApiSchool school;
  final List<GradeBooklist> grades;

  List<BooklistProduct> get allProducts =>
      grades.expand((g) => g.products).toList();

  factory SchoolBooklist.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] as Map? ?? {});
    final schoolMap = Map<String, dynamic>.from(
      (data['school'] ?? const {}) as Map,
    );
    final gradesRaw = data['grades'] as List? ?? [];
    return SchoolBooklist(
      school: ApiSchool.fromJson(schoolMap),
      grades: gradesRaw
          .map((e) => GradeBooklist.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

@immutable
final class DeliveryInfo {
  const DeliveryInfo({
    required this.orderId,
    required this.orderStatus,
    required this.shippingStatus,
    this.trackingId,
  });

  final int orderId;
  final String? orderStatus;
  final String? shippingStatus;
  final String? trackingId;

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) => DeliveryInfo(
        orderId: json['order_id'] as int? ?? 0,
        orderStatus: json['order_status'] as String?,
        shippingStatus: json['shipping_status'] as String?,
        trackingId: json['tracking_id'] as String?,
      );

  static DeliveryInfo fromResponse(Map<String, dynamic> body) {
    final data = Map<String, dynamic>.from(
      (body['data'] ?? const {}) as Map? ?? {},
    );
    return DeliveryInfo.fromJson(data);
  }
}

@immutable
final class PaymentStatus {
  const PaymentStatus({
    required this.status,
    this.amount,
    this.orderId,
    this.orderStatus,
    this.paidAt,
    this.message,
  });

  final String status;
  final double? amount;
  final int? orderId;
  final String? orderStatus;
  final String? paidAt;
  final String? message;

  factory PaymentStatus.fromJson(Map<String, dynamic> json) => PaymentStatus(
        status: (json['status'] ?? 'unknown') as String,
        amount: json['amount'] == null ? null : _toDouble(json['amount']),
        orderId: json['order_id'] as int?,
        orderStatus: json['order_status'] as String?,
        paidAt: json['paid_at'] as String?,
        message: json['message'] as String?,
      );
}

@immutable
final class StkPushResult {
  const StkPushResult({
    required this.success,
    required this.message,
    this.merchantRequestId,
    this.checkoutRequestId,
    this.responseCode,
    this.responseDescription,
  });

  final bool success;
  final String message;
  final String? merchantRequestId;
  final String? checkoutRequestId;
  final String? responseCode;
  final String? responseDescription;

  factory StkPushResult.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(
      (json['data'] ?? const {}) as Map? ?? {},
    );
    return StkPushResult(
      success: json['success'] as bool? ?? false,
      message: (json['message'] ?? '') as String,
      merchantRequestId: data['MerchantRequestID'] as String?,
      checkoutRequestId: data['CheckoutRequestID'] as String?,
      responseCode: '${data['ResponseCode'] ?? ''}',
      responseDescription: data['ResponseDescription'] as String?,
    );
  }
}

@immutable
final class ApiProduct {
  const ApiProduct({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    this.originalPrice,
    this.priceFormatted,
    this.salePercent,
    this.imageUrl,
    this.description,
    this.quantity,
    this.isOutOfStock,
    this.stockStatusLabel,
    this.reviewsAvg,
    this.reviewsCount,
    this.categories,
    this.brand,
    this.isFeatured,
  });

  final int id;
  final String name;
  final String slug;
  final double price;
  final double? originalPrice;
  final String? priceFormatted;
  final double? salePercent;
  final String? imageUrl;
  final String? description;
  final int? quantity;
  final bool? isOutOfStock;
  final String? stockStatusLabel;
  final double? reviewsAvg;
  final int? reviewsCount;
  final List<ProductCategory>? categories;
  final Brand? brand;
  final bool? isFeatured;

  bool get inStock => isOutOfStock != true;

  double get effectivePrice => (originalPrice != null && originalPrice! < price)
      ? originalPrice!
      : price;

  String get displayPrice => priceFormatted ?? 'KES${price.toStringAsFixed(2)}';

  factory ApiProduct.fromJson(Map<String, dynamic> json) => ApiProduct(
        id: json['id'] as int? ?? 0,
        name: (json['name'] ?? '') as String,
        slug: (json['slug'] ?? '') as String,
        price: _toDouble(json['price']),
        originalPrice:
            json['original_price'] == null ? null : _toDouble(json['original_price']),
        priceFormatted: json['price_formatted'] as String?,
        salePercent:
            json['sale_percent'] == null ? null : _toDouble(json['sale_percent']),
        imageUrl: json['image_url'] as String?,
        description: json['description'] as String?,
        quantity: json['quantity'] as int?,
        isOutOfStock: json['is_out_of_stock'] as bool?,
        stockStatusLabel: json['stock_status_label'] as String?,
        reviewsAvg: json['reviews_avg'] == null ? null : _toDouble(json['reviews_avg']),
        reviewsCount: json['reviews_count'] as int?,
        categories: (json['categories'] as List? ?? [])
            .map((e) =>
                ProductCategory.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        brand: json['brand'] == null
            ? null
            : Brand.fromJson(Map<String, dynamic>.from(json['brand'] as Map)),
        isFeatured: json['is_featured'] != null
            ? json['is_featured'] == 1 || json['is_featured'] == true
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'price': price,
        if (originalPrice != null) 'original_price': originalPrice,
        if (priceFormatted != null) 'price_formatted': priceFormatted,
        if (salePercent != null) 'sale_percent': salePercent,
        if (imageUrl != null) 'image_url': imageUrl,
        if (description != null) 'description': description,
        if (quantity != null) 'quantity': quantity,
        if (isOutOfStock != null) 'is_out_of_stock': isOutOfStock,
        if (stockStatusLabel != null) 'stock_status_label': stockStatusLabel,
        if (reviewsAvg != null) 'reviews_avg': reviewsAvg,
        if (reviewsCount != null) 'reviews_count': reviewsCount,
        if (categories != null)
          'categories': categories!.map((c) => c.toJson()).toList(),
        if (brand != null) 'brand': brand!.toJson(),
        if (isFeatured != null) 'is_featured': isFeatured,
      };
}

@immutable
final class ProductCategory {
  const ProductCategory({
    required this.id,
    required this.name,
    this.slug,
    this.icon,
    this.parentId,
    this.isFeatured,
  });

  final int id;
  final String name;
  final String? slug;
  final String? icon;
  final int? parentId;
  final bool? isFeatured;

  factory ProductCategory.fromJson(Map<String, dynamic> json) =>
      ProductCategory(
        id: json['id'] as int? ?? 0,
        name: (json['name'] ?? '') as String,
        slug: json['slug'] as String?,
        icon: json['icon'] as String?,
        parentId: json['parent_id'] as int?,
        isFeatured: json['is_featured'] != null
            ? json['is_featured'] == 1 || json['is_featured'] == true
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (slug != null) 'slug': slug,
        if (icon != null) 'icon': icon,
        if (parentId != null) 'parent_id': parentId,
        if (isFeatured != null) 'is_featured': isFeatured,
      };
}

@immutable
final class Brand {
  const Brand({
    required this.id,
    this.name,
    this.slug,
    this.logo,
    this.image,
    this.isFeatured = false,
  });

  final bool isFeatured;

  final int id;
  final String? name;
  final String? slug;
  final String? logo;
  final String? image;

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String?,
        slug: json['slug'] as String?,
        logo: (json['logo_with_sizes'] is Map
                ? (json['logo_with_sizes']['thumb'] ??
                    json['logo_with_sizes']['origin'])
                : json['logo'])
            as String?,
        image: json['image'] as String?,
        isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        if (name != null) 'name': name,
        if (slug != null) 'slug': slug,
        if (logo != null) 'logo': logo,
        if (image != null) 'image': image,
      };
}

@immutable
final class CartItem {
  const CartItem({
    required this.id,
    required this.name,
    required this.qty,
    required this.price,
    this.options,
    this.rowId,
  });

  final int id;
  final String name;
  final int qty;
  final double price;
  final Map<String, dynamic>? options;
  final String? rowId;

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'] as int? ?? 0,
        name: (json['name'] ?? '') as String,
        qty: (json['qty'] ?? json['quantity']) as int? ?? 1,
        price: _toDouble(json['price']),
        options: json['options'] as Map<String, dynamic>?,
        rowId: (json['rowId'] ?? json['row_id']) as String?,
      );
}

@immutable
final class CartResponse {
  const CartResponse({
    required this.error,
    this.count,
    this.totalPrice,
    this.items,
    required this.message,
    this.cartId,
    this.couponDiscount = 0,
    this.appliedCouponCode,
  });

  final double couponDiscount;
  final String? appliedCouponCode;
  final bool error;
  final int? count;
  final String? totalPrice;
  final List<CartItem>? items;
  final String message;
  final String? cartId;

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['cart_items'] ??
        json['content'] ??
        (json['data'] is Map ? (json['data'] as Map)['items'] : null);
    final List itemsList = rawItems is List
        ? rawItems
        : rawItems is Map
            ? rawItems.values.toList()
            : const [];
    return CartResponse(
      couponDiscount: _toDouble(json['coupon_discount_amount']),
      appliedCouponCode: json['applied_coupon_code']?.toString(),
      error: json['error'] as bool? ?? false,
      count: json['count'] as int? ?? (json['data'] is Map ? (json['data'] as Map)['count'] as int? : null),
      totalPrice: (json['order_total_formatted'] ?? json['raw_total_formatted'] ?? (json['data'] is Map ? (json['data'] as Map)['total_price'] : null))?.toString(),
      items: itemsList
          .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      message: (json['message'] ?? '') as String,
      cartId: json['id']?.toString(),
    );
  }
}

@immutable
final class ApiOrder {
  const ApiOrder({
    required this.id,
    this.code,
    this.status,
    this.total,
    this.currency,
    this.paymentMethod,
    this.shippingMethod,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String? code;
  final String? status;
  final double? total;
  final String? currency;
  final String? paymentMethod;
  final String? shippingMethod;
  final String? createdAt;
  final String? updatedAt;

  factory ApiOrder.fromJson(Map<String, dynamic> json) => ApiOrder(
        id: json['id'] as int? ?? 0,
        code: json['code'] as String?,
        status: json['status'] as String?,
        total: _toDouble(json['total']),
        currency: json['currency'] as String?,
        paymentMethod: json['payment_method'] as String?,
        shippingMethod: json['shipping_method'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
      );
}

@immutable
final class Address {
  const Address({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.country,
    this.state,
    this.city,
    this.address,
    this.zipCode,
    this.isDefault,
  });

  final int id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? country;
  final String? state;
  final String? city;
  final String? address;
  final String? zipCode;
  final bool? isDefault;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'] as int? ?? 0,
        firstName: json['first_name'] as String?,
        lastName: json['last_name'] as String?,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        country: json['country'] as String?,
        state: json['state'] as String?,
        city: json['city'] as String?,
        address: json['address'] as String?,
        zipCode: json['zip_code'] as String?,
        isDefault: json['is_default'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (country != null) 'country': country,
        if (state != null) 'state': state,
        if (city != null) 'city': city,
        if (address != null) 'address': address,
        if (zipCode != null) 'zip_code': zipCode,
        if (isDefault != null) 'is_default': isDefault,
      };
}

@immutable
final class Review {
  const Review({
    required this.id,
    required this.productId,
    required this.customerId,
    required this.rating,
    this.comment,
    this.status,
    this.createdAt,
  });

  final int id;
  final int productId;
  final int customerId;
  final int rating;
  final String? comment;
  final String? status;
  final String? createdAt;

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as int? ?? 0,
        productId: json['product_id'] as int? ?? 0,
        customerId: json['customer_id'] as int? ?? 0,
        rating: json['rating'] as int? ?? 0,
        comment: json['comment'] as String?,
        status: json['status'] as String?,
        createdAt: json['created_at'] as String?,
      );
}

@immutable
final class OrderReturn {
  const OrderReturn({
    required this.id,
    this.orderId,
    this.status,
    this.reason,
    this.createdAt,
  });

  final int id;
  final int? orderId;
  final String? status;
  final String? reason;
  final String? createdAt;

  factory OrderReturn.fromJson(Map<String, dynamic> json) => OrderReturn(
        id: json['id'] as int? ?? 0,
        orderId: json['order_id'] as int?,
        status: json['status'] as String?,
        reason: json['reason'] as String?,
        createdAt: json['created_at'] as String?,
      );
}

@immutable
final class DownloadItem {
  const DownloadItem({
    required this.id,
    this.productId,
    this.fileName,
    this.filePath,
    this.createdAt,
  });

  final int id;
  final int? productId;
  final String? fileName;
  final String? filePath;
  final String? createdAt;

  factory DownloadItem.fromJson(Map<String, dynamic> json) => DownloadItem(
        id: json['id'] as int? ?? 0,
        productId: json['product_id'] as int?,
        fileName: json['file_name'] as String?,
        filePath: json['file_path'] as String?,
        createdAt: json['created_at'] as String?,
      );
}

@immutable
final class WishlistItem {
  const WishlistItem({
    required this.id,
    required this.name,
    this.slug,
    this.price,
    this.salePrice,
    this.image,
  });

  final int id;
  final String name;
  final String? slug;
  final double? price;
  final double? salePrice;
  final String? image;

  factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
        id: json['id'] as int? ?? 0,
        name: (json['name'] ?? '') as String,
        slug: json['slug'] as String?,
        price: _toDouble(json['price']),
        salePrice: json['sale_price'] == null
            ? null
            : _toDouble(json['sale_price']),
        image: json['image'] as String?,
      );
}

@immutable
final class Country {
  const Country({required this.id, this.name, this.code});

  final String id;
  final String? name;
  final String? code;

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        id: (json['id'] ?? '') as String,
        name: json['name'] as String?,
        code: json['code'] as String?,
      );
}

@immutable
final class Currency {
  const Currency({required this.id, this.title, this.symbol, this.code});

  final int id;
  final String? title;
  final String? symbol;
  final String? code;

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String?,
        symbol: json['symbol'] as String?,
        code: json['code'] as String?,
      );
}

@immutable
final class TaxResult {
  const TaxResult({this.tax, this.subtotal, this.total});

  final double? tax;
  final double? subtotal;
  final double? total;

  factory TaxResult.fromJson(Map<String, dynamic> json) => TaxResult(
        tax: _toDouble(json['tax']),
        subtotal: _toDouble(json['subtotal']),
        total: _toDouble(json['total']),
      );
}

@immutable
final class CouponResult {
  const CouponResult({required this.error, this.message, this.data});

  final bool error;
  final String? message;
  final Map<String, dynamic>? data;

  factory CouponResult.fromJson(Map<String, dynamic> json) => CouponResult(
        error: json['error'] as bool? ?? false,
        message: json['message'] as String?,
        data: json['data'] as Map<String, dynamic>?,
      );
}

@immutable
final class SocialLoginResult {
  const SocialLoginResult({
    required this.token,
    this.tokenType,
    this.user,
  });

  final String token;
  final String? tokenType;
  final UserProfile? user;

  factory SocialLoginResult.fromJson(Map<String, dynamic> json) =>
      SocialLoginResult(
        token: (json['token'] ?? json['access_token'] ?? '') as String,
        tokenType: json['token_type'] as String?,
        user: json['customer'] != null
            ? UserProfile.fromJson(
                Map<String, dynamic>.from(json['customer'] as Map))
            : (json['user'] != null
                ? UserProfile.fromJson(
                    Map<String, dynamic>.from(json['user'] as Map))
                : null),
      );
}

@immutable
final class SliderItem {
  const SliderItem({
    required this.id,
    this.title,
    this.image,
    this.url,
  });

  final int id;
  final String? title;
  final String? image;
  final String? url;

  factory SliderItem.fromJson(Map<String, dynamic> json) => SliderItem(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String?,
        image: json['image'] as String?,
        url: json['url'] as String?,
      );
}

@immutable
final class SliderData {
  const SliderData({required this.id, this.name, this.slug, this.items});

  final int id;
  final String? name;
  final String? slug;
  final List<SliderItem>? items;

  factory SliderData.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];
    return SliderData(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      items: rawItems
          .map((e) =>
              SliderItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

@immutable
final class AdItem {
  const AdItem({
    required this.id,
    this.name,
    this.key,
    this.html,
    this.isActive,
  });

  final int id;
  final String? name;
  final String? key;
  final String? html;
  final bool? isActive;

  factory AdItem.fromJson(Map<String, dynamic> json) => AdItem(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String?,
        key: json['key'] as String?,
        html: json['html'] as String?,
        isActive: json['is_active'] as bool?,
      );
}

@immutable
final class BlogPost {
  const BlogPost({
    required this.id,
    this.name,
    this.slug,
    this.content,
    this.image,
    this.status,
    this.authorId,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String? name;
  final String? slug;
  final String? content;
  final String? image;
  final String? status;
  final int? authorId;
  final String? createdAt;
  final String? updatedAt;

  factory BlogPost.fromJson(Map<String, dynamic> json) => BlogPost(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String?,
        slug: json['slug'] as String?,
        content: json['content'] as String?,
        image: json['image'] as String?,
        status: json['status'] as String?,
        authorId: json['author_id'] as int?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
      );
}

@immutable
final class BlogCategoryItem {
  const BlogCategoryItem({
    required this.id,
    this.name,
    this.slug,
    this.description,
    this.postsCount,
  });

  final int id;
  final String? name;
  final String? slug;
  final String? description;
  final int? postsCount;

  factory BlogCategoryItem.fromJson(Map<String, dynamic> json) =>
      BlogCategoryItem(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String?,
        slug: json['slug'] as String?,
        description: json['description'] as String?,
        postsCount: json['posts_count'] as int?,
      );
}

@immutable
final class BlogTagItem {
  const BlogTagItem({required this.id, this.name, this.slug});

  final int id;
  final String? name;
  final String? slug;

  factory BlogTagItem.fromJson(Map<String, dynamic> json) => BlogTagItem(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String?,
        slug: json['slug'] as String?,
      );
}

@immutable
final class LanguageItem {
  const LanguageItem({
    required this.id,
    this.langCode,
    this.langName,
    this.flag,
  });

  final int id;
  final String? langCode;
  final String? langName;
  final String? flag;

  factory LanguageItem.fromJson(Map<String, dynamic> json) => LanguageItem(
        id: json['id'] as int? ?? 0,
        langCode: json['lang_code'] as String?,
        langName: json['lang_name'] as String?,
        flag: json['flag'] as String?,
      );
}

@immutable
final class SearchSuggestion {
  const SearchSuggestion({
    required this.type,
    this.id,
    this.name,
    this.url,
    this.image,
  });

  final String type;
  final int? id;
  final String? name;
  final String? url;
  final String? image;

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) =>
      SearchSuggestion(
        type: (json['type'] ?? 'product') as String,
        id: json['id'] as int?,
        name: json['name'] as String?,
        url: json['url'] as String?,
        image: json['image'] as String?,
      );
}

@immutable
final class SearchResultData {
  const SearchResultData({required this.data, this.total, this.raw});

  final List<Map<String, dynamic>> data;
  final int? total;
  final Map<String, dynamic>? raw;

  factory SearchResultData.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    if (rawData is List) {
      return SearchResultData(
        data: rawData.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
        total: json['total'] as int?,
        raw: json,
      );
    }
    if (rawData is Map) {
      final items = <Map<String, dynamic>>[];
      for (final entry in rawData.entries) {
        final v = entry.value;
        if (v is Map && v['items'] is List) {
          for (final it in (v['items'] as List)) {
            final m = Map<String, dynamic>.from(it as Map);
            m['__type'] = entry.key.toString();
            items.add(m);
          }
        }
      }
      return SearchResultData(data: items, total: json['total'] as int?, raw: json);
    }
    return SearchResultData(data: const [], total: json['total'] as int?, raw: json);
  }
}

@immutable
final class AnalyticsOverview {
  const AnalyticsOverview({
    this.revenue,
    this.ordersCount,
    this.customersCount,
    this.conversionRate,
  });

  final double? revenue;
  final int? ordersCount;
  final int? customersCount;
  final double? conversionRate;

  factory AnalyticsOverview.fromJson(Map<String, dynamic> json) =>
      AnalyticsOverview(
        revenue: _toDouble(json['revenue']),
        ordersCount: json['orders_count'] as int?,
        customersCount: json['customers_count'] as int?,
        conversionRate: _toDouble(json['conversion_rate']),
      );
}

@immutable
final class GenericResponse {
  const GenericResponse({required this.error, this.message, this.data});

  final bool error;
  final String? message;
  final dynamic data;

  factory GenericResponse.fromJson(Map<String, dynamic> json) =>
      GenericResponse(
        error: json['error'] as bool? ?? false,
        message: json['message'] as String?,
        data: json['data'],
      );
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
