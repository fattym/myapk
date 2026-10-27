import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../utils/formatters.dart';

class TradeInModal extends StatefulWidget {
  const TradeInModal({super.key});

  @override
  State<TradeInModal> createState() => _TradeInModalState();
}

class _TradeInModalState extends State<TradeInModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  String? _selectedGrade;
  String? _selectedCondition;

  final Map<String, int> _conditionCredits = {
    'New': 400,
    'Good': 300,
    'Fair': 250,
    'Poor': 100,
  };

  final List<String> _grades = [
    'Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5',
    'Grade 6', 'Grade 7', 'Grade 8', 'JSS 1', 'JSS 2', 'JSS 3',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  int get _perBookCredit => _conditionCredits[_selectedCondition] ?? 0;
  int get _quantity => int.tryParse(_quantityController.text) ?? 1;
  int get _totalCredit => _perBookCredit * _quantity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Sell / Trade-In Books',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryPurple,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            // Form
            Form(
              key: _formKey,
              child: Column(
                 children: [
                  // Book Title
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Book Title',
                      prefixIcon: const Icon(Icons.menu_book, color: AppColors.primaryPurple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a book title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Author
                  TextFormField(
                    controller: _authorController,
                    decoration: InputDecoration(
                      labelText: 'Author',
                      prefixIcon: const Icon(Icons.person, color: AppColors.primaryPurple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Grade Level
                  FormField<String>(
                    builder: (FormFieldState<String> field) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Grade Level',
                          prefixIcon: const Icon(Icons.school, color: AppColors.primaryPurple),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedGrade,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: _grades.map((grade) {
                            return DropdownMenuItem(
                              value: grade,
                              child: Text(grade),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedGrade = value);
                            field.didChange(value);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Condition
                  FormField<String>(
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a condition';
                      }
                      return null;
                    },
                    builder: (FormFieldState<String> field) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Condition',
                          prefixIcon: const Icon(Icons.star, color: AppColors.primaryPurple),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorText: field.errorText,
                        ),
                        child: DropdownButton<String>(
                          value: _selectedCondition,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: _conditionCredits.keys.map((condition) {
                            return DropdownMenuItem(
                              value: condition,
                              child: Text(condition),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedCondition = value);
                            field.didChange(value);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Quantity
                  TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      prefixIcon: const Icon(Icons.numbers, color: AppColors.primaryPurple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            // Credit display
            Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightGold,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Estimated Credit',
                    style: TextStyle(color: AppColors.darkPurple, fontSize: 12),
                  ),
                  Text(
                    formatKES(_totalCredit.toDouble()),
                    style: const TextStyle(
                      color: AppColors.darkPurple,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_selectedCondition != null)
                    Text(
                      '$_perBookCredit KES per book x $_quantity book${_quantity != 1 ? 's' : ''}',
                      style: const TextStyle(color: AppColors.darkPurple, fontSize: 11),
                    ),
                ],
              ),
            ),
            // Submit button
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: _selectedCondition == null
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() ?? false) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Trade-in submitted! Credit: ${formatKES(_totalCredit.toDouble())}',
                                ),
                                backgroundColor: AppColors.primaryPurple,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: AppColors.surfaceWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Trade-In Request',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
