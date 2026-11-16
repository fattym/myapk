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
    bool matches(Department d) =>
        q.isEmpty ||
        d.name.toLowerCase().contains(q) ||
        catalog.childrenOf(d).any(matches);
    List<Department> kidsOf(Department d) => catalog
        .childrenOf(d)
        .where((k) => d.name.toLowerCase().contains(q) || matches(k))
        .toList();
    final tops = catalog.topDepartments.where(matches).toList();

    Widget node(Department d, int depth) {
      final kids = kidsOf(d);
      void go(Department x) =>
          openCategory(context, x, () => widget.onNavigateToTab?.call(2));
      final pad = EdgeInsets.only(left: 16.0 + depth * 14);
      if (kids.isEmpty) {
        return ListTile(
          dense: depth > 0,
          contentPadding: depth == 0 ? null : pad,
          title: Text(d.name,
              style: TextStyle(
                  fontWeight: depth == 0 ? FontWeight.w600 : FontWeight.w400)),
          trailing: depth == 0 ? const Icon(Icons.chevron_right) : null,
          onTap: () => go(d),
        );
      }
      return ExpansionTile(
        key: PageStorageKey('cat-${d.id}'),
        initiallyExpanded: q.isNotEmpty,
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: depth == 0 ? null : pad,
        title: Text(d.name,
            style: TextStyle(
                fontWeight: depth == 0 ? FontWeight.w600 : FontWeight.w500)),
        children: [
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.only(left: 16.0 + (depth + 1) * 14),
            title: Text('All ${d.name}'),
            onTap: () => go(d),
          ),
          for (final k in kids) node(k, depth + 1),
        ],
      );
    }
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
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        clipBehavior: Clip.antiAlias,
                        child: node(tops[i], 0),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
