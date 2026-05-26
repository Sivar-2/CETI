import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/cart_provider.dart';
import 'core/providers/inventory_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/dashboard_provider.dart';
import 'core/providers/orders_provider.dart';
import 'core/providers/loyalty_provider.dart';
import 'core/providers/ai_messaging_provider.dart';
import 'core/providers/nfc_provider.dart';

// CONNECTED — Firebase is configured:
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:ui';
import 'dart:isolate';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // CONNECTED — Initialize Firebase:
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Poka-Yoke Telemetry Lock: Catch all unhandled Flutter errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Catch all unhandled asynchronous Dart errors silently
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Catch isolate errors
  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      StackTrace.fromString(errorAndStacktrace.last.toString()),
      fatal: true,
    );
  }).sendPort);

  // Initialize auth provider
  final authProvider = AuthProvider();
  await authProvider.init();

  final inventoryProvider = InventoryProvider();
  await inventoryProvider.init();

  final loyaltyProvider = LoyaltyProvider();

  // Analytics Instance initialization (just to ensure it boots, though global access is via instance)
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: inventoryProvider),
        ChangeNotifierProvider.value(value: loyaltyProvider),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()..init()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()..init()),
        ChangeNotifierProvider(create: (_) => NfcProvider()),
        ChangeNotifierProxyProvider2<InventoryProvider, DashboardProvider, AiMessagingProvider>(
          create: (context) => AiMessagingProvider(
            inventory: context.read<InventoryProvider>(),
            dashboard: context.read<DashboardProvider>(),
          ),
          update: (_, inventory, dashboard, prev) => 
            prev ?? AiMessagingProvider(inventory: inventory, dashboard: dashboard),
        ),
      ],
      child: CetiApp(authProvider: authProvider),
    ),
  );
}

class CetiApp extends StatelessWidget {
  const CetiApp({super.key, required this.authProvider});
  
  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CETI — Business SuperApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: buildAppRouter(authProvider),
    );
  }
}
