import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_header.dart';
import '../models/department.dart';
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
    List<Department> kidsOf(Department d) => catalog
        .childrenOf(d)
        .where((k) => q.isEmpty || k.name.toLowerCase().contains(q) ||
            d.name.toLowerCase().contains(q))
        .toList();
    final tops = catalog.topDepartments.where((d) {
      if (q.isEmpty || d.name.toLowerCase().contains(q)) return true;
      return kidsOf(d).isNotEmpty;
    }).toList();
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
            child: tops.isEmpty
                ? const Center(child: Text('No categories found'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: tops.length,
                    itemBuilder: (context, i) {
                      final d = tops[i];
                      final kids = kidsOf(d);
                      void go(Department x) => openCategory(context, x,
                          () => widget.onNavigateToTab?.call(2));
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        clipBehavior: Clip.antiAlias,
                        child: kids.isEmpty
                            ? ListTile(
                                title: Text(d.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => go(d),
                              )
                            : ExpansionTile(
                                key: PageStorageKey(d.id),
                                initiallyExpanded: q.isNotEmpty,
                                shape: const Border(),
                                collapsedShape: const Border(),
                                title: Text(d.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text('${kids.length} categories'),
                                children: [
                                  ListTile(
                                    dense: true,
                                    title: Text('All ${d.name}'),
                                    onTap: () => go(d),
                                  ),
                                  for (final k in kids)
                                    ListTile(
                                      dense: true,
                                      title: Text(k.name),
                                      onTap: () => go(k),
                                    ),
                                ],
                              ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
