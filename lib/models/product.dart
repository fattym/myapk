import 'package:flutter/foundation.dart';
import 'api_models.dart';

@immutable
class Product {
  final int id;
  final String title;
  final String category;
  final String publisher;
  final double newPrice;
  final double? preOwnedPrice;
  final String conditionState;
  final String grade;
  final String iconName;
  final String? imageUrl;
  final String? slug;
  final double? oldPrice;

  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.publisher,
    required this.newPrice,
    this.preOwnedPrice,
    this.conditionState = 'new',
    required this.grade,
    required this.iconName,
    this.imageUrl,
    this.slug,
    this.oldPrice,
  });

  /// Builds a UI product from a live API product.
  factory Product.fromApi(ApiProduct p) => Product(
        id: p.id,
        title: p.name,
        category: (p.categories != null && p.categories!.isNotEmpty)
            ? p.categories!.first.name
            : '',
        publisher: p.brand?.name ?? '',
        newPrice: p.effectivePrice,
        grade: '',
        iconName: 'book',
        imageUrl: p.imageUrl,
        slug: p.slug,
        oldPrice: (p.originalPrice != null && p.originalPrice! > p.effectivePrice)
            ? p.originalPrice
            : null,
      );

  Product copyWith({
    int? id,
    String? title,
    String? category,
    String? publisher,
    double? newPrice,
    double? preOwnedPrice,
    String? conditionState,
    String? grade,
    String? iconName,
    String? imageUrl,
    String? slug,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      publisher: publisher ?? this.publisher,
      newPrice: newPrice ?? this.newPrice,
      preOwnedPrice: preOwnedPrice ?? this.preOwnedPrice,
      conditionState: conditionState ?? this.conditionState,
      grade: grade ?? this.grade,
      iconName: iconName ?? this.iconName,
      imageUrl: imageUrl ?? this.imageUrl,
      slug: slug ?? this.slug,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'publisher': publisher,
      'newPrice': newPrice,
      'preOwnedPrice': preOwnedPrice,
      'conditionState': conditionState,
      'grade': grade,
      'iconName': iconName,
      'imageUrl': imageUrl,
      'slug': slug,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      publisher: json['publisher'] as String,
      newPrice: (json['newPrice'] as num).toDouble(),
      preOwnedPrice: json['preOwnedPrice'] != null
          ? (json['preOwnedPrice'] as num).toDouble()
          : null,
      conditionState: json['conditionState'] as String? ?? 'new',
      grade: json['grade'] as String,
      iconName: json['iconName'] as String,
      imageUrl: json['imageUrl'] as String?,
      slug: json['slug'] as String?,
    );
  }

  /// True when the live price is below the list price (sale / promotion).
  /// Discounts above 90% are treated as bad data and not advertised.
  bool get isDiscounted =>
      oldPrice != null && oldPrice! > newPrice && newPrice * 10 >= oldPrice!;

  /// Percentage off, rounded (null when not discounted).
  int? get discountPercent => isDiscounted
      ? (((oldPrice! - newPrice) / oldPrice!) * 100).round().clamp(1, 99)
      : null;

  double get currentPrice {
    if (conditionState == 'preowned' && preOwnedPrice != null) {
      return preOwnedPrice!;
    }
    return newPrice;
  }
}
