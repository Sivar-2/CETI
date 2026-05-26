import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ceti_app/main.dart';

import 'package:provider/provider.dart';
import 'package:ceti_app/core/providers/cart_provider.dart';
import 'package:ceti_app/core/providers/inventory_provider.dart';
import 'package:ceti_app/core/providers/auth_provider.dart';

void main() {
  testWidgets('CETI app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => InventoryProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: CetiApp(authProvider: AuthProvider()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
