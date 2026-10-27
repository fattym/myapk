import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/colors.dart';
import '../../utils/formatters.dart';

class MpesaStkModal extends StatefulWidget {
  final double totalAmount;

  const MpesaStkModal({
    super.key,
    required this.totalAmount,
  });

  @override
  State<MpesaStkModal> createState() => _MpesaStkModalState();
}

class _MpesaStkModalState extends State<MpesaStkModal> {
  final _phoneController = TextEditingController(text: '+254 797 100 500');
  bool _isProcessing = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Pay via M-Pesa STK Push',
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
            // Total amount display
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightGold,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(color: AppColors.darkPurple, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    formatKES(widget.totalAmount),
                    style: const TextStyle(
                      color: AppColors.darkPurple,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Phone number input
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'M-Pesa Phone Number',
                hintText: '+254 797 100 500',
                   prefixIcon: const FaIcon(
                     FontAwesomeIcons.phone,
                     color: AppColors.primaryPurple,
                     size: 16,
                   ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.accentGold, width: 2),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            Text(
              'Ensure this number is registered with Safaricom M-Pesa',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            // STK Push button
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _sendStkPush,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: AppColors.surfaceWhite,
                            strokeWidth: 2,
                          ),
                        )
                      : const FaIcon(FontAwesomeIcons.mobileScreenButton, size: 18),
                  label: Text(
                    _isProcessing ? 'Sending STK Push...' : 'Send STK Push',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: AppColors.darkPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendStkPush() {
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('STK Push sent to ${_phoneController.text}! Complete payment to confirm.'),
          backgroundColor: AppColors.primaryPurple,
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }
}
