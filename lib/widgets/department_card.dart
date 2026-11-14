import 'package:flutter/material.dart';
import '../models/department.dart';
import '../utils/icons.dart';

class DepartmentCard extends StatelessWidget {
  final Department department;
  final VoidCallback? onTap;

  const DepartmentCard({
    super.key,
    required this.department,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EEF8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  getIconForName(department.iconName),
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                department.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                department.itemCount > 0
                    ? '${department.itemCount} items'
                    : (department.subtitle.isNotEmpty
                        ? department.subtitle
                        : 'Browse all'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
