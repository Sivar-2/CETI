import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/ceti_bottom_nav.dart';

/// Shell widget that persists the bottom nav across all main screens.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});
  final Widget child;

  static const _routes = ['/home', '/pos', '/inventory', '/inbox', '/loyalty'];

  int _indexFromRoute(String location) {
    for (int i = 0; i < _routes.length; i++) {
      if (location.startsWith(_routes[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _indexFromRoute(location);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: child,
      bottomNavigationBar: CetiBottomNav(
        currentIndex: index,
        onTap: (i) => context.go(_routes[i]),
      ),
      extendBody: true,
    );
  }
}
