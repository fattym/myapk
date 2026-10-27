import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/products.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../theme/colors.dart';
import '../../utils/formatters.dart';
import '../../utils/icons.dart';

class OcrScannerModal extends StatefulWidget {
  const OcrScannerModal({super.key});

  @override
  State<OcrScannerModal> createState() => _OcrScannerModalState();
}

class _OcrScannerModalState extends State<OcrScannerModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  bool _scanning = true;
  final List<Product> _matchedItems = [];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true, period: const Duration(seconds: 3));

    Future.delayed(const Duration(seconds: 4), _completeScan);
  }

  void _completeScan() {
    _scanController.stop();
    setState(() {
      _scanning = false;
      _matchedItems.addAll([
        sampleProducts[0],
        sampleProducts[1],
        sampleProducts[3],
        sampleProducts[6],
      ]);
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: _scanning ? _buildScanningView() : _buildResultsView(),
          ),
        ),
      ),
    );
  }

  Widget _buildScanningView() {
    final double viewfinderSize =
        (MediaQuery.of(context).size.width - 48).clamp(240.0, 320.0);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: const Text(
                  'AI Booklist Scanner',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ],
          ),
        ),
        const Spacer(),
        Center(
          child: Container(
            width: viewfinderSize,
            height: viewfinderSize,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accentGold, width: 2),
            ),
            child: Stack(
              children: [
                // Simulated camera preview
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.qr_code_scanner,
                      color: Colors.grey,
                      size: 80,
                    ),
                  ),
                ),
                // Scanning line animation
                AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, child) {
                    final position = _scanController.value * (viewfinderSize - 2);
                    return Positioned(
                      top: position,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.accentGold,
                              Colors.transparent,
                            ],
                            tileMode: TileMode.clamp,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Corner markers
                Positioned(
                  top: 8,
                  left: 8,
                  child: _corner(Icons.square, AppColors.accentGold),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _corner(Icons.square, AppColors.accentGold),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: _corner(Icons.square, AppColors.accentGold),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: _corner(Icons.square, AppColors.accentGold),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        // Status text
        Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'AI Extracting Textbook Names & Quantities...',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: null,
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _corner(IconData icon, Color color) {
    return Icon(icon, color: color, size: 20);
  }

  Widget _buildResultsView() {
    return Column(
      children: [
        // Header
        Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: const Text(
              'Matched KICD Items',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
          ),
        ],
      ),
    ),
        const SizedBox(height: 8),
        // Matched items count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${_matchedItems.length} items matched from your booklist',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ),
        // Matched items list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _matchedItems.length,
            itemBuilder: (context, index) {
              final product = _matchedItems[index];
              return Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    getIconForName(product.iconName),
                    color: AppColors.accentGold,
                    size: 28,
                  ),
                  title: Text(
                    product.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${product.publisher} \u2022 Grade ${product.grade}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  trailing: Text(
                    formatKES(product.newPrice),
                    style: TextStyle(
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Action buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final cart = context.read<CartProvider>();
                    for (final product in _matchedItems) {
                      cart.addItem(product);
                    }
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${_matchedItems.length} items added to cart'),
                        backgroundColor: AppColors.primaryPurple,
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Add All Matched Items to Cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: AppColors.darkPurple,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Add Individual Items',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
