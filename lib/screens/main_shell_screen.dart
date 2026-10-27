import 'package:flutter/material.dart';
import '../screens/cart_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/catalog_screen.dart';
import '../screens/home_screen.dart';
import '../screens/schools_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/modals/ocr_scanner_modal.dart';
import '../widgets/modals/trade_in_modal.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _navigateToCart() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );
  }

  void _showOcrScanner() {
    showDialog(
      context: context,
      builder: (context) => const OcrScannerModal(),
    );
  }

  void _showTradeInModal() {
    showDialog(
      context: context,
      builder: (context) => const TradeInModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onCartTap: _navigateToCart,
        onAiScanTap: _showOcrScanner,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            onScanTap: _showOcrScanner,
            onSearchSchoolTap: () => _navigateToTab(3),
            onNavigateToTab: _navigateToTab,
            onTradeInTap: _showTradeInModal,
          ),
          CategoriesScreen(onNavigateToTab: _navigateToTab),
          const CatalogScreen(),
          const SchoolsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
