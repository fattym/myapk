import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/schools_provider.dart';
import 'screens/main_shell_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => SchoolsProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
      ],
      child: MaterialApp(
        title: 'MyBidhaa',
        theme: AppTheme.lightTheme,
        home: const MainShellScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
