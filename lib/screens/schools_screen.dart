import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/api_models.dart';
import '../models/partner_school.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/schools_provider.dart';
import '../theme/colors.dart';
import '../utils/formatters.dart';
import '../widgets/app_header.dart';
import '../widgets/school_picker.dart';

/// "Find my booklist": pick a school, filter by grade, add the list to cart or
/// order it over WhatsApp. Data comes from /v1/schools and /booklist.
class SchoolsScreen extends StatefulWidget {
  const SchoolsScreen({super.key});

  @override
  State<SchoolsScreen> createState() => _SchoolsScreenState();
}

class _SchoolsScreenState extends State<SchoolsScreen> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<SchoolsProvider>().loadSchools(),
    );
  }

  Product _toProduct(BooklistProduct p, String grade) => Product(
        id: p.id,
        title: p.name,
        category: '',
        publisher: '',
        newPrice: p.effectivePrice,
        grade: grade,
        iconName: 'book',
        imageUrl: p.image,
      );

  List<GradeBooklist> _shown(SchoolBooklist b, int? gradeId) =>
      gradeId == null
          ? b.grades
          : b.grades.where((g) => g.id == gradeId).toList();

  double _total(List<GradeBooklist> grades) => grades.fold(
        0.0,
        (sum, g) =>
            sum +
            g.products.fold(0.0, (s, p) => s + p.effectivePrice * p.quantity),
      );

  void _addAll(BuildContext context, List<GradeBooklist> grades) {
    final cart = context.read<CartProvider>();
    var count = 0;
    for (final g in grades) {
      for (final p in g.products) {
        cart.addItem(_toProduct(p, g.name), quantity: p.quantity);
        count += p.quantity;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$count books added to cart'),
        backgroundColor: AppColors.primaryPurple,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _whatsApp(
      String school, List<GradeBooklist> grades, double total) async {
    final b = StringBuffer('MyBidhaa booklist order\n$school\n\n');
    for (final g in grades) {
      b.writeln(g.name);
      for (final p in g.products) {
        b.writeln(
            '- ${p.name} x${p.quantity} = ${formatKES(p.effectivePrice * p.quantity)}');
      }
      b.writeln();
    }
    b.writeln('TOTAL: ${formatKES(total)}');
    b.writeln('\nI would like to order this booklist. Please confirm.');
    final uri = Uri.parse(
        'https://wa.me/254797100500?text=${Uri.encodeComponent(b.toString())}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final schools = context.watch<SchoolsProvider>();
    final school = schools.selectedSchool;
    final apiId = school?.apiId;
    final booklist = apiId == null ? null : schools.booklistFor(apiId);
    final loading =
        apiId != null && booklist == null && !schools.booklistFailed(apiId);
    final failed =
        apiId != null && booklist == null && schools.booklistFailed(apiId);

    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenHeader(
            title: 'Find my booklist',
            subtitle: 'Pick your school and grade to see every required book',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _SchoolSelector(
                  name: school?.name,
                  onTap: () => showSchoolPicker(context),
                ),
                const SizedBox(height: 16),
                if (school == null)
                  _SchoolSearchList(
                    query: _query,
                    onQuery: (v) => setState(() => _query = v),
                    onPick: (s) => context.read<SchoolsProvider>().selectSchool(s),
                  )
                else if (apiId == null)
                  const _Notice(
                      'This school\'s booklist is not available yet. Please try another school.')
                else if (loading)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (failed)
                  _Retry(
                    message:
                        schools.errorMessage ?? 'Failed to load the booklist.',
                    onRetry: () => context
                        .read<SchoolsProvider>()
                        .loadBooklist(apiId: apiId),
                  )
                else if (booklist != null)
                  ..._content(context, schools, school.name, booklist),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _content(BuildContext context, SchoolsProvider schools,
      String schoolName, SchoolBooklist booklist) {
    if (booklist.grades.isEmpty) {
      return const [_Notice('No booklist available for this school yet.')];
    }
    final gradeId = booklist.grades.any((g) => g.id == schools.selectedGradeId)
        ? schools.selectedGradeId
        : null;
    final shown = _shown(booklist, gradeId);
    final total = _total(shown);
    final bookCount = shown.fold<int>(0, (s, g) => s + g.products.length);

    return [
      const Text(
        'GRADE',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.4,
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _GradeChip(
              label: 'All',
              selected: gradeId == null,
              onTap: () => context.read<SchoolsProvider>().selectGrade(null),
            ),
            for (final g in booklist.grades)
              _GradeChip(
                label: g.name,
                selected: gradeId == g.id,
                onTap: () => context.read<SchoolsProvider>().selectGrade(g.id),
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.dividerColor),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      gradeId == null
                          ? 'Full booklist'
                          : '${shown.first.name} booklist',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '$bookCount books',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            for (final g in shown) ...[
              if (gradeId == null)
                Container(
                  width: double.infinity,
                  color: AppColors.subtlePurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    g.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ),
              if (g.products.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No books listed for this grade',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              for (final p in g.products) _BookRow(product: p),
            ],
          ],
        ),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkPurple,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Expanded(
                  child: Text('Booklist total',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ),
                Text(
                  formatKES(total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: bookCount == 0 ? null : () => _addAll(context, shown),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGold,
                  foregroundColor: const Color(0xFF2A1240),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: const Text('Add all to cart'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: bookCount == 0
                    ? null
                    : () => _whatsApp(schoolName, shown, total),
                icon: const Icon(Icons.chat_outlined, size: 20),
                label: const Text('Order via WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF147A3F),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}

class _SchoolSelector extends StatelessWidget {
  final String? name;
  final VoidCallback onTap;
  const _SchoolSelector({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'School: ${name ?? "not selected"}',
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.dividerColor),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.subtlePurple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.school_outlined,
                    color: AppColors.primaryPurple, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('School',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    Text(
                      name ?? 'Select your school',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            name == null ? FontWeight.w400 : FontWeight.w600,
                        color: name == null
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _GradeChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? Colors.white : AppColors.textPrimary,
        ),
        selectedColor: AppColors.primaryPurple,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? AppColors.primaryPurple : AppColors.dividerColor,
        ),
        shape: const StadiumBorder(),
      ),
    );
  }
}

class _BookRow extends StatelessWidget {
  final BooklistProduct product;
  const _BookRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.dividerColor)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 44,
              height: 58,
              color: AppColors.subtlePurple,
              child: (product.image != null && product.image!.isNotEmpty)
                  ? Image.network(
                      product.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(Icons.menu_book,
                          color: AppColors.primaryPurple),
                    )
                  : const Icon(Icons.menu_book,
                      color: AppColors.primaryPurple),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.quantity} required',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatKES(product.effectivePrice),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryPurple,
            ),
          ),
        ],
      ),
    );
  }
}

class _SchoolSearchList extends StatelessWidget {
  final String query;
  final ValueChanged<String> onQuery;
  final ValueChanged<PartnerSchool> onPick;
  const _SchoolSearchList({
    required this.query,
    required this.onQuery,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final schools = context.watch<SchoolsProvider>();
    final q = query.trim().toLowerCase();
    final matches = schools.schools
        .where((s) => q.isEmpty || s.name.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final list = matches; // show every school (A-Z), not just the first 60
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSearchField(
          hint: 'Search by school name',
          initialValue: query,
          onChanged: onQuery,
        ),
        const SizedBox(height: 16),
        if (schools.status == SchoolsStatus.loading && schools.schools.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          Text(
            q.isEmpty
                ? '${matches.length} PARTNER SCHOOLS'
                : '${matches.length} MATCHING SCHOOLS',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          if (list.isEmpty)
            const _Notice('No school matches your search.')
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < list.length; i++) ...[
                    if (i > 0) const Divider(height: 1, indent: 16),
                    ListTile(
                      leading: const Icon(Icons.school_outlined,
                          color: AppColors.primaryPurple),
                      title: Text(
                        list[i].name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: list[i].location.isEmpty
                          ? null
                          : Text(list[i].location),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => onPick(list[i]),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  final String text;
  const _Notice(this.text);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerColor),
        ),
        child: Text(text,
            style: const TextStyle(color: AppColors.textSecondary)),
      );
}

class _Retry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _Retry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _Notice(message),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      );
}
