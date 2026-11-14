import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schools_provider.dart';
import '../theme/colors.dart';
import 'school_picker.dart';

/// "Find your school's booklist" card: pick a school and grade, then jump to
/// the Schools tab. (Replaces the old static promo banner.)
class HeroBanner extends StatelessWidget {
  final VoidCallback? onScanTap;
  final VoidCallback? onSearchSchoolTap;

  const HeroBanner({
    super.key,
    this.onScanTap,
    this.onSearchSchoolTap,
  });

  @override
  Widget build(BuildContext context) {
    final schools = context.watch<SchoolsProvider>();
    final school = schools.selectedSchool;
    final apiId = school?.apiId;
    final booklist = apiId == null ? null : schools.booklistFor(apiId);
    String gradeLabel = 'Select grade';
    if (booklist != null && schools.selectedGradeId != null) {
      for (final g in booklist.grades) {
        if (g.id == schools.selectedGradeId) gradeLabel = g.name;
      }
    } else if (booklist != null) {
      gradeLabel = 'All grades';
    }
    final gradeEnabled = booklist != null && booklist.grades.isNotEmpty;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.darkPurple,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accentGold,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'CBC approved 2026',
              style: TextStyle(
                color: AppColors.darkPurple,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Find your school's booklist in seconds",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          _PickerButton(
            label: school?.name ?? 'Select your school',
            filled: school != null,
            solid: true,
            onTap: () => showSchoolPicker(context),
          ),
          const SizedBox(height: 8),
          _PickerButton(
            label: school == null ? 'Select grade' : gradeLabel,
            filled: schools.selectedGradeId != null,
            solid: false,
            enabled: gradeEnabled,
            onTap: () => showGradePicker(context),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: school == null
                  ? () => showSchoolPicker(context)
                  : onSearchSchoolTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGold,
                foregroundColor: const Color(0xFF2A1240),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              child: const Text('Find my list'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  final String label;
  final bool filled;
  final bool solid;
  final bool enabled;
  final VoidCallback onTap;

  const _PickerButton({
    required this.label,
    required this.filled,
    required this.solid,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final fg = solid
        ? (filled ? AppColors.textPrimary : AppColors.textSecondary)
        : Colors.white.withValues(alpha: enabled ? 1 : 0.7);
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onTap : null,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: solid ? Colors.white : Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontSize: 15,
                    fontWeight: filled ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              Icon(Icons.keyboard_arrow_down,
                  color: solid ? AppColors.textSecondary : Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
