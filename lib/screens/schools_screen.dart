import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/products.dart';
import '../models/api_models.dart';
import '../models/partner_school.dart';
import '../models/product.dart';
import '../providers/schools_provider.dart';
import '../theme/colors.dart';
import '../utils/formatters.dart';
import '../widgets/school_card.dart';

class SchoolsScreen extends StatefulWidget {
  const SchoolsScreen({super.key});

  @override
  State<SchoolsScreen> createState() => _SchoolsScreenState();
}

class _SchoolsScreenState extends State<SchoolsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    Provider.of<SchoolsProvider>(context, listen: false).loadSchools();
  }

  List<Product> _sampleBooklistForSchool(String schoolName) {
    final gradeMap = <String, String>{
      'Kilimani Junior': 'Grade 2',
      'Moi Educational': 'Grade 8',
      "St. Mary's": 'Grade 5',
      'Brookhouse': 'Grade 7',
    };
    final grade = gradeMap[schoolName];
    if (grade == null) return [];
    return sampleProducts.where((p) => p.grade == grade).toList();
  }

  void _showBooklist(PartnerSchool school) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _SchoolBooklistDialog(
        school: school,
        sampleProducts: _sampleBooklistForSchool(school.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      body: Consumer<SchoolsProvider>(
        builder: (context, schoolsProvider, _) {
          final schools = schoolsProvider.schools;
          final isLoading =
              schoolsProvider.status == SchoolsStatus.loading && schools.isEmpty;
          final isError = schoolsProvider.status == SchoolsStatus.error &&
              schools.isEmpty;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (isError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  schoolsProvider.errorMessage ??
                      'Unable to load schools. Please try again.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (schools.isEmpty) {
            return const Center(child: Text('No schools found.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: schools.length,
            itemBuilder: (context, index) {
              final school = schools[index];
              return SchoolCard(
                school: school,
                onTap: () => _showBooklist(school),
              );
            },
          );
        },
      ),
    );
  }
}

class _SchoolBooklistDialog extends StatefulWidget {
  const _SchoolBooklistDialog({required this.school, this.sampleProducts});

  final PartnerSchool school;
  final List<Product>? sampleProducts;

  @override
  State<_SchoolBooklistDialog> createState() => _SchoolBooklistDialogState();
}

class _SchoolBooklistDialogState extends State<_SchoolBooklistDialog> {
  int? _selectedGradeId; // null = all grades

  int? get _apiId => widget.school.apiId;

  @override
  void initState() {
    super.initState();
    final id = _apiId;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<SchoolsProvider>().loadBooklist(apiId: id);
        }
      });
    }
  }

  void _retry() {
    final id = _apiId;
    if (id != null) context.read<SchoolsProvider>().loadBooklist(apiId: id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SchoolsProvider>();
    final id = _apiId;
    final SchoolBooklist? booklist = id == null ? null : provider.booklistFor(id);
    final bool loading =
        id != null && booklist == null && !provider.booklistFailed(id);
    final bool failed =
        id != null && booklist == null && provider.booklistFailed(id);

    return AlertDialog(
      backgroundColor: AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.school, color: AppColors.primaryPurple),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.school.name,
              style: theme.textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: loading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            : failed
                ? Text(provider.errorMessage ?? 'Failed to load booklist.')
                : SingleChildScrollView(child: _buildContent(context, booklist)),
      ),
      actions: [
        if (failed)
          TextButton.icon(
            icon: const Icon(Icons.refresh, size: 16),
            onPressed: _retry,
            label: const Text('Retry'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, SchoolBooklist? booklist) {
    final theme = Theme.of(context);
    final header = Text(
      '${widget.school.location} \u2022 ${widget.school.code}',
      style: const TextStyle(color: Colors.grey, fontSize: 13),
    );

    if (booklist != null) {
      final all = booklist.grades;
      if (all.isEmpty) return const Text('No booklist available');
      // Keep selection valid if the data changed.
      final selected = all.any((g) => g.id == _selectedGradeId)
          ? _selectedGradeId
          : null;
      final shown =
          selected == null ? all : all.where((g) => g.id == selected).toList();
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            value: selected,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Select grade',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('All grades'),
              ),
              ...all.map((g) => DropdownMenuItem<int?>(
                    value: g.id,
                    child: Text(g.name, overflow: TextOverflow.ellipsis),
                  )),
            ],
            onChanged: (v) => setState(() => _selectedGradeId = v),
          ),
          const SizedBox(height: 12),
          ...shown.map((grade) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    grade.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (grade.products.isEmpty)
                    const Text('No books listed for this grade',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ...grade.products.map((product) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(product.name,
                            style: const TextStyle(fontSize: 13)),
                        subtitle: Text(
                          '${product.quantity} required \u2022 ${formatKES(product.effectivePrice)}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      )),
                  const SizedBox(height: 8),
                ],
              )),
        ],
      );
    }

    final books = widget.sampleProducts ?? [];
    if (books.isEmpty) return const Text('No booklist available');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        header,
        const SizedBox(height: 12),
        ...books.map((product) => ListTile(
              leading: const Icon(Icons.book,
                  color: AppColors.primaryPurple, size: 20),
              title: Text(product.title, style: const TextStyle(fontSize: 13)),
              subtitle: Text(
                '${product.publisher} \u2022 ${formatKES(product.newPrice)}',
                style: const TextStyle(fontSize: 11),
              ),
            )),
      ],
    );
  }
}
