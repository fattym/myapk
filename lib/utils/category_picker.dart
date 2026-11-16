import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/department.dart';
import '../providers/app_provider.dart';
import '../providers/catalog_provider.dart';

/// Selects a category; when it has sub-categories (e.g. grades) the user picks
/// one first. Calls [go] once a category has been chosen.
Future<void> openCategory(
    BuildContext context, Department d, VoidCallback go) async {
  final catalog = context.read<CatalogProvider>();
  final app = context.read<AppProvider>();
  final kids = catalog.childrenOf(d);
  if (kids.isEmpty) {
    app.setSelectedCategory(d.name, id: catalog.categoryIdFor(d));
    go();
    return;
  }
  final picked = await showModalBottomSheet<Department>(
    context: context,
    backgroundColor: Colors.white,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (sheet) => ListView(
      shrinkWrap: true,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(d.name,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        ),
        ListTile(
          title: Text('All ${d.name}'),
          onTap: () => Navigator.of(sheet).pop(d),
        ),
        for (final k in kids)
          ListTile(
            title: Text(k.name),
            onTap: () => Navigator.of(sheet).pop(k),
          ),
      ],
    ),
  );
  if (picked == null) return;
  app.setSelectedCategory(picked.name, id: catalog.categoryIdFor(picked));
  go();
}
