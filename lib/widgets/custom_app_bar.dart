import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../data/departments.dart';
import '../models/student_profile.dart';
import '../providers/app_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/colors.dart';
import '../utils/formatters.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onCartTap;
  final VoidCallback? onAiScanTap;

  const CustomAppBar({
    super.key,
    this.onCartTap,
    this.onAiScanTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(170);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row: Profile dropdown + AI Scan + Cart
          Row(
             crossAxisAlignment: CrossAxisAlignment.center,
             children: [
               // Profile dropdown
               Expanded(
                 child: Consumer<ProfileProvider>(
                   builder: (context, profileProvider, child) {
                     return PopupMenuButton<StudentProfile>(
                       onSelected: (profile) {
                         final index = profileProvider.profiles.indexOf(profile);
                         profileProvider.switchProfile(index);
                       },
                       itemBuilder: (context) =>
                           profileProvider.profiles.asMap().entries.map((entry) {
                         final profile = entry.value;
                         return PopupMenuItem<StudentProfile>(
                           value: profile,
                           child: Row(
                             children: [
                               Icon(
                                 Icons.school,
                                 color: entry.key == profileProvider.selectedIndex
                                     ? AppColors.primaryPurple
                                     : Colors.grey,
                                 size: 16,
                               ),
                               const SizedBox(width: 8),
                               Expanded(
                                 child: Text(
                                   profile.displayName,
                                   style: TextStyle(
                                     color: entry.key == profileProvider.selectedIndex
                                         ? AppColors.primaryPurple
                                         : Colors.black87,
                                     fontWeight: entry.key == profileProvider.selectedIndex
                                         ? FontWeight.w600
                                         : FontWeight.normal,
                                   ),
                                   maxLines: 1,
                                   overflow: TextOverflow.ellipsis,
                                 ),
                               ),
                             ],
                           ),
                         );
                       }).toList(),
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(12),
                       ),
                       child: ConstrainedBox(
                         constraints: const BoxConstraints(maxWidth: 200),
                         child: Row(
                           children: [
                             const Icon(
                               Icons.person,
                               color: AppColors.primaryPurple,
                               size: 20,
                             ),
                             const SizedBox(width: 4),
                             Expanded(
                               child: Text(
                                 profileProvider.selectedProfile.shortDisplay,
                                 style: Theme.of(context)
                                     .textTheme
                                     .bodySmall
                                     ?.copyWith(
                                       color: AppColors.textSecondary,
                                       fontWeight: FontWeight.w600,
                                     ),
                                 maxLines: 1,
                                 overflow: TextOverflow.ellipsis,
                               ),
                             ),
                             const Icon(
                               Icons.arrow_drop_down,
                               color: AppColors.textSecondary,
                               size: 20,
                             ),
                           ],
                         ),
                       ),
                     );
                   },
                 ),
               ),
               const SizedBox(width: 8),
               // AI Scan button
               TextButton.icon(
                 onPressed: widget.onAiScanTap,
                 icon: const FaIcon(
                   FontAwesomeIcons.camera,
                   size: 14,
                   color: AppColors.primaryPurple,
                 ),
                 label: const Text(
                   'AI Scan',
                   style: TextStyle(
                     color: AppColors.primaryPurple,
                     fontSize: 12,
                     fontWeight: FontWeight.w600,
                   ),
                   maxLines: 1,
                   overflow: TextOverflow.ellipsis,
                 ),
               ),
               // Cart icon with badge
               Consumer<CartProvider>(
                 builder: (context, cart, child) {
                   return GestureDetector(
                     onTap: widget.onCartTap,
                     child: Stack(
                       children: [
                         const Icon(
                           Icons.shopping_cart,
                           color: AppColors.primaryPurple,
                           size: 24,
                         ),
                         if (cart.totalCartItems > 0)
                           Positioned(
                             top: 2,
                             right: 2,
                             child: Container(
                               padding: const EdgeInsets.all(4),
                               decoration: BoxDecoration(
                                 color: AppColors.accentGold,
                                 shape: BoxShape.circle,
                               ),
                               child: Text(
                                 cart.totalCartItems.toString(),
                                 style: TextStyle(
                                   color: AppColors.darkPurple,
                                   fontSize: 10,
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                             ),
                           ),
                       ],
                     ),
                   );
                 },
               ),
               const SizedBox(width: 6),
               // Cart total
               Expanded(
                 child: Consumer<CartProvider>(
                   builder: (context, cart, child) {
                     return Text(
                       cart.total > 0 ? formatKES(cart.total) : 'Empty',
                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
                             color: AppColors.textSecondary,
                             fontWeight: FontWeight.w600,
                           ),
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                       textAlign: TextAlign.end,
                     );
                   },
                 ),
               ),
             ],
           ),
          const SizedBox(height: 8),
          // Department filter dropdown
           Row(
             children: [
               Expanded(
                 child: Consumer<AppProvider>(
                   builder: (context, appProvider, child) {
                     final selectedValue = appProvider.selectedCategory ?? 'All Departments';
                     return Container(
                       padding: const EdgeInsets.symmetric(horizontal: 12),
                       decoration: BoxDecoration(
                         border: Border.all(
                           color: AppColors.dividerColor,
                           width: 1,
                         ),
                         borderRadius: BorderRadius.circular(12),
                       ),
                       child: DropdownButton<String>(
                         value: selectedValue,
                         items: [
                           const DropdownMenuItem(
                             value: 'All Departments',
                             child: Text('All Departments'),
                           ),
                           ...sampleDepartments.map(
                             (d) => DropdownMenuItem(
                               value: d.name,
                               child: Text(d.name),
                             ),
                           ),
                         ],
                         onChanged: (value) {
                           if (value == null || value == 'All Departments') {
                             appProvider.setSelectedCategory(null);
                           } else {
                             appProvider.setSelectedCategory(value);
                           }
                         },
                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
                               color: AppColors.textPrimary,
                             ),
                         underline: const SizedBox(),
                         isDense: true,
                         icon: const Icon(
                           Icons.arrow_drop_down,
                           color: AppColors.textSecondary,
                           size: 20,
                         ),
                       ),
                     );
                   },
                 ),
               ),
             ],
           ),
          const SizedBox(height: 8),
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for books, stationery...',
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.textSecondary,
                size: 20,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              filled: true,
              fillColor: AppColors.subtlePurple.withValues(alpha: 0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryPurple,
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              context.read<AppProvider>().setSearchQuery(value);
            },
          ),
        ],
      ),
    );
  }
}
