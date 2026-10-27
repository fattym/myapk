import 'package:flutter/material.dart';
import '../models/student_profile.dart';

class ProfileProvider extends ChangeNotifier {
  final List<StudentProfile> _profiles = [
    const StudentProfile(
      id: 1,
      name: 'Amina Hassan',
      grade: 'Grade 2',
      schoolName: 'Kilimani Junior',
    ),
    const StudentProfile(
      id: 2,
      name: 'David Ochieng',
      grade: 'Grade 8 JSS',
      schoolName: 'Moi Educational',
    ),
    const StudentProfile(
      id: 3,
      name: 'Sarah Wanjiru',
      grade: 'Grade 5',
      schoolName: "St. Mary's",
    ),
  ];

  int _selectedIndex = 0;

  List<StudentProfile> get profiles => List.unmodifiable(_profiles);
  int get selectedIndex => _selectedIndex;

  StudentProfile get selectedProfile => _profiles[_selectedIndex];

  set selectedIndex(int value) {
    if (value >= 0 && value < _profiles.length) {
      _selectedIndex = value;
      notifyListeners();
    }
  }

  void switchProfile(int index) {
    if (index >= 0 && index < _profiles.length) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void addProfile(StudentProfile profile) {
    _profiles.add(profile);
    notifyListeners();
  }
}
