import 'package:flutter/foundation.dart';

@immutable
class StudentProfile {
  final int id;
  final String name;
  final String grade;
  final String schoolName;

  const StudentProfile({
    required this.id,
    required this.name,
    required this.grade,
    required this.schoolName,
  });

  String get displayName => '$name, $grade - $schoolName';

  String get shortDisplay {
    final parts = schoolName.split(' ');
    final shortSchool = parts.length > 1 ? parts.sublist(0, 2).join(' ') : schoolName;
    return '$name ($grade - $shortSchool)';
  }

  StudentProfile copyWith({
    int? id,
    String? name,
    String? grade,
    String? schoolName,
  }) {
    return StudentProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      schoolName: schoolName ?? this.schoolName,
    );
  }
}
