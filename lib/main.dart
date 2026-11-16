import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/schools_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_shell_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/update_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  UpdateService.check(); // Play in-app update prompt (Android)
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => SchoolsProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
      ],
      child: MaterialApp(
        title: 'MyBidhaa',
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          // Keep layouts intact for very large system font sizes.
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(
              textScaler: mq.textScaler.clamp(
                  minScaleFactor: 0.9, maxScaleFactor: 1.4),
            ),
            child: child!,
          );
        },
        home: const _StartGate(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Shows the onboarding once on first launch, then the main app.
class _StartGate extends StatelessWidget {
  const _StartGate();

  Future<bool> _done() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(onboardingDoneKey) ?? false;
    } catch (_) {
      return true; // never block the app if storage is unavailable
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _done(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snap.data! ? const MainShellScreen() : const OnboardingScreen();
      },
    );
  }
}
