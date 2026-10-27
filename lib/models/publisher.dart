import 'package:flutter/foundation.dart';

@immutable
class Publisher {
  final String name;
  final String iconName;

  const Publisher({
    required this.name,
    required this.iconName,
  });
}
