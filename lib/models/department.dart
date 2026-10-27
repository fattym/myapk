import 'package:flutter/foundation.dart';

@immutable
class Department {
  final String id;
  final String name;
  final String subtitle;
  final int itemCount;
  final String iconName;

  const Department({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.itemCount,
    required this.iconName,
  });
}
