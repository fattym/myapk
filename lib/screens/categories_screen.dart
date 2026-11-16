import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_header.dart';
import '../widgets/department_card.dart';
import '../utils/category_picker.dart';
import '../providers/catalog_provider.dart';
import '../theme/colors.dart';

class CategoriesScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const CategoriesScreen({super.key, this.onNavigateToTab});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<CatalogProvider>().loadCategories(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final q = _query.trim().toLowerCase();
    final departments = catalog.departments
        .where((d) => q.isEmpty || d.name.toLowerCase().contains(q))
        .toList();
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenHeader(
            title: 'Categories',
            subtitle: 'Browse the full MyBidhaa range',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: AppSearchField(
              hint: 'Search categories',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: departments.isEmpty
                ? const Center(child: Text('No categories found'))
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      mainAxisExtent: 132 *
                          (0.6 +
                              0.4 *
                                  MediaQuery.textScalerOf(context)
                                      .scale(1.0)
                                      .clamp(1.0, 1.4)),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: departments.length,
                    itemBuilder: (context, index) {
                      final department = departments[index];
                      return DepartmentCard(
                        department: department,
                        onTap: () => openCategory(context, department,
                            () => widget.onNavigateToTab?.call(2)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
