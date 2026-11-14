import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/partner_school.dart';
import '../providers/schools_provider.dart';
import '../theme/colors.dart';

/// Searchable bottom sheet to choose a school.
Future<void> showSchoolPicker(BuildContext context) async {
  final provider = context.read<SchoolsProvider>();
  if (provider.status == SchoolsStatus.idle) provider.loadSchools();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _SchoolSheet(),
  );
}

class _SchoolSheet extends StatefulWidget {
  const _SchoolSheet();

  @override
  State<_SchoolSheet> createState() => _SchoolSheetState();
}

class _SchoolSheetState extends State<_SchoolSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SchoolsProvider>();
    final q = _query.trim().toLowerCase();
    final List<PartnerSchool> schools = provider.schools
        .where((s) => q.isEmpty || s.name.toLowerCase().contains(q))
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Select your school',
                    style:
                        TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                autofocus: false,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Type to search for your school',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: AppColors.backgroundNeutral,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: provider.status == SchoolsStatus.loading &&
                      provider.schools.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : schools.isEmpty
                      ? const Center(child: Text('No schools found'))
                      : ListView.separated(
                          itemCount: schools.length,
                          separatorBuilder: (_, _) =>
                              const Divider(height: 1, indent: 20),
                          itemBuilder: (context, i) {
                            final school = schools[i];
                            final selected =
                                provider.selectedSchool?.name == school.name;
                            return ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              title: Text(school.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              subtitle: school.location.isEmpty
                                  ? null
                                  : Text(school.location),
                              trailing: selected
                                  ? const Icon(Icons.check_circle,
                                      color: AppColors.primaryPurple)
                                  : null,
                              onTap: () {
                                provider.selectSchool(school);
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet to choose a grade of the selected school.
Future<void> showGradePicker(BuildContext context) async {
  final provider = context.read<SchoolsProvider>();
  final id = provider.selectedSchool?.apiId;
  final grades = id == null ? null : provider.booklistFor(id)?.grades;
  if (grades == null || grades.isEmpty) return;
  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Text('Select grade',
                style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: const Text('All grades'),
            trailing: provider.selectedGradeId == null
                ? const Icon(Icons.check_circle,
                    color: AppColors.primaryPurple)
                : null,
            onTap: () {
              provider.selectGrade(null);
              Navigator.of(sheetContext).pop();
            },
          ),
          for (final g in grades)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: Text(g.name),
              trailing: provider.selectedGradeId == g.id
                  ? const Icon(Icons.check_circle,
                      color: AppColors.primaryPurple)
                  : null,
              onTap: () {
                provider.selectGrade(g.id);
                Navigator.of(sheetContext).pop();
              },
            ),
        ],
      ),
    ),
  );
}
