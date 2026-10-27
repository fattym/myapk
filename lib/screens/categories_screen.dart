import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/departments.dart';
import '../widgets/department_card.dart';
import '../providers/app_provider.dart';
import '../theme/colors.dart';

class CategoriesScreen extends StatelessWidget {
  final Function(int)? onNavigateToTab;

  const CategoriesScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: sampleDepartments.length,
        itemBuilder: (context, index) {
          final department = sampleDepartments[index];
          return DepartmentCard(
            department: department,
            onTap: () {
              context.read<AppProvider>().setSelectedCategory(department.name);
              onNavigateToTab?.call(2);
            },
          );
        },
      ),
    );
  }
}
