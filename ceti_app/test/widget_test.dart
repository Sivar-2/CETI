import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ceti_app/main.dart';

import 'package:provider/provider.dart';
import 'package:ceti_app/core/providers/cart_provider.dart';
import 'package:ceti_app/core/providers/inventory_provider.dart';

void main() {
  testWidgets('CETI app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => InventoryProvider()..loadMockData()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: const CetiApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
