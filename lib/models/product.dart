import 'package:flutter/foundation.dart';

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
  });

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
    );
  }

  double get currentPrice {
    if (conditionState == 'preowned' && preOwnedPrice != null) {
      return preOwnedPrice!;
    }
    return newPrice;
  }
}
