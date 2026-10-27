import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mybidhaa/providers/app_provider.dart';
import 'package:mybidhaa/providers/auth_provider.dart';
import 'package:mybidhaa/providers/cart_provider.dart';
import 'package:mybidhaa/providers/profile_provider.dart';
import 'package:mybidhaa/providers/schools_provider.dart';
import 'package:mybidhaa/screens/cart_screen.dart';
import 'package:mybidhaa/screens/main_shell_screen.dart';
import 'package:mybidhaa/widgets/modals/mpesa_stk_modal.dart';
import 'package:mybidhaa/widgets/modals/ocr_scanner_modal.dart';
import 'package:mybidhaa/widgets/modals/trade_in_modal.dart';

void main() {
  Future<void> pumpAt(
    WidgetTester tester,
    Size logicalSize,
    Widget home, {
    EdgeInsets viewInsets = EdgeInsets.zero,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = logicalSize;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final prevOnError = FlutterError.onError;
    FlutterError.onError = FlutterError.dumpErrorToConsole;
    addTearDown(() => FlutterError.onError = prevOnError);

    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: logicalSize, viewInsets: viewInsets),
        child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => AppProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => SchoolsProvider()),
        ],
          child: MaterialApp(home: home),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final exc = tester.takeException();
    expect(exc, isNull, reason: 'overflow at ${logicalSize.width.toInt()}x${logicalSize.height.toInt()} for $home');
  }

  testWidgets('shell renders all tabs without overflow at 320x568',
      (t) => pumpAt(t, const Size(320, 568), const MainShellScreen()));
  testWidgets('shell renders all tabs without overflow at 375x667',
      (t) => pumpAt(t, const Size(375, 667), const MainShellScreen()));

  testWidgets('cart renders without overflow at 320x568',
      (t) => pumpAt(t, const Size(320, 568), const CartScreen()));
  testWidgets('cart renders without overflow at 375x667',
      (t) => pumpAt(t, const Size(375, 667), const CartScreen()));

  testWidgets('trade_in renders without overflow at 320x568',
      (t) => pumpAt(t, const Size(320, 568), const TradeInModal()));
  testWidgets('ocr_scanner renders without overflow at 320x568',
      (t) => pumpAt(t, const Size(320, 568), const OcrScannerModal()));
  testWidgets('mpesa_stk renders without overflow at 320x568',
      (t) => pumpAt(t, const Size(320, 568), const MpesaStkModal(totalAmount: 1250)));

  testWidgets('trade_in with keyboard insets renders without overflow at 320x568',
      (t) => pumpAt(
            t,
            const Size(320, 568),
            const TradeInModal(),
            viewInsets: const EdgeInsets.only(bottom: 256),
          ));
}

