import 'package:flutter/foundation.dart';

@immutable
class PartnerSchool {
  final String name;
  final String code;
  final String location;
  final int studentCount;
  final String? contact;
  final String? logoUrl;
  final int? apiId;

  const PartnerSchool({
    required this.name,
    required this.code,
    required this.location,
    required this.studentCount,
    this.contact,
    this.logoUrl,
    this.apiId,
  });

  bool get isRemote => contact != null && contact!.isNotEmpty;

  String get subtitle =>
      (studentCount > 0 ? '$studentCount students' : contact?.isNotEmpty == true ? contact! : '');

  PartnerSchool copyWith({
    String? name,
    String? code,
    String? location,
    int? studentCount,
    String? contact,
    String? logoUrl,
    int? apiId,
  }) {
    return PartnerSchool(
      name: name ?? this.name,
      code: code ?? this.code,
      location: location ?? this.location,
      studentCount: studentCount ?? this.studentCount,
      contact: contact ?? this.contact,
      logoUrl: logoUrl ?? this.logoUrl,
      apiId: apiId ?? this.apiId,
    );
  }
}
