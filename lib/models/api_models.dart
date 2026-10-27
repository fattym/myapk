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

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
