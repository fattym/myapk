import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/products.dart';
import '../models/api_models.dart';
import '../models/partner_school.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
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
    final authenticated =
        Provider.of<AuthProvider>(context, listen: false).isAuthenticated;
    Provider.of<SchoolsProvider>(context, listen: false)
        .loadSchools(authenticated: authenticated);
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
    final authenticated =
        Provider.of<AuthProvider>(context, listen: false).isAuthenticated;
    final provider = Provider.of<SchoolsProvider>(context, listen: false);

    final bool useApi = authenticated && school.apiId != null;
    final SchoolBooklist? booklist = useApi ? provider.booklistFor(school.apiId!) : null;

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        if (useApi && booklist == null) {
          // Trigger an on-demand fetch the first time the dialog opens.
          provider.loadBooklist(
              authenticated: authenticated, apiId: school.apiId!);
        }
        return _SchoolBooklistDialog(
          school: school,
          booklist: useApi ? provider.booklistFor(school.apiId!) : null,
          sampleProducts:
              useApi ? null : _sampleBooklistForSchool(school.name),
          onRetry: useApi
              ? () {
                  provider.loadBooklist(
                      authenticated: authenticated, apiId: school.apiId!);
                  setState(() {});
                }
              : null,
        );
      },
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

class _SchoolBooklistDialog extends StatelessWidget {
  const _SchoolBooklistDialog({
    required this.school,
    this.booklist,
    this.sampleProducts,
    this.onRetry,
  });

  final PartnerSchool school;
  final SchoolBooklist? booklist;
  final List<Product>? sampleProducts;
  final VoidCallback? onRetry;

  bool get _isApi => booklist != null || sampleProducts == null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool loading = _isApi && (booklist == null && onRetry != null);

    return AlertDialog(
      backgroundColor: AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          const Icon(Icons.school, color: AppColors.primaryPurple),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              school.name,
              style: theme.textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.infinity,
        child: loading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            : _buildContent(context),
      ),
      actions: [
        if (onRetry != null)
          TextButton.icon(
            icon: const Icon(Icons.refresh, size: 16),
            onPressed: onRetry,
            label: const Text('Retry'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);

    if (_isApi) {
      final grades = booklist?.grades ?? [];
      if (grades.isEmpty) {
        return const Text('No booklist available');
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${school.location} \u2022 ${school.code}',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          ...grades.map((grade) => Column(
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
                  ...grade.products.map((product) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          product.name,
                          style: const TextStyle(fontSize: 13),
                        ),
                        subtitle: Text(
                          '${product.quantity} required \u2022 ${formatKES(product.effectivePrice)}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      )),
                ],
              )),
        ],
      );
    }

    final books = sampleProducts ?? [];
    if (books.isEmpty) {
      return const Text('No booklist available');
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${school.location} \u2022 ${school.code}',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 12),
        ...books.map((product) => ListTile(
              leading: const Icon(
                Icons.book,
                color: AppColors.primaryPurple,
                size: 20,
              ),
              title: Text(
                product.title,
                style: const TextStyle(fontSize: 13),
              ),
              subtitle: Text(
                '${product.publisher} \u2022 ${formatKES(product.newPrice)}',
                style: const TextStyle(fontSize: 11),
              ),
            )),
      ],
    );
  }
}
