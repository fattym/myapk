import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mybidhaa/main.dart';

void main() {
  testWidgets('Home screen renders with navigation and product sections',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Recommended for You'), findsOneWidget);
    expect(find.text('Shop by Department'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Catalog'), findsOneWidget);
    expect(find.text('Schools'), findsOneWidget);
  });

  testWidgets('Adding a product to cart makes it visible in the cart screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final addButton = find.text('Add to Cart').first;
    await tester.ensureVisible(addButton);
    await tester.pumpAndSettle();
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // The cart badge in the app bar should now show 1 item.
    expect(find.text('1'), findsOneWidget);

    // Tap the cart icon in the app bar to open the cart screen.
    await tester.tap(find.byIcon(Icons.shopping_cart).first);
    await tester.pumpAndSettle();

    expect(find.text('My Cart'), findsOneWidget);
    expect(find.text('Items in Cart (1)'), findsOneWidget);
    expect(find.text('Grade 4 Mathematics'), findsOneWidget);
  });
}
