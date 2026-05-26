import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ceti_bottom_nav.dart';
import '../inbox/widgets/ai_assistant_drawer.dart';

/// Shell widget that persists the bottom nav across all main screens.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});
  final Widget child;

  static const _routes = ['/home', '/orders', '/inventory', '/loyalty'];

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
      appBar: AppBar(
        title: Text(
          'CETI',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          // Inbox/Messages AI icon button
          Builder(
            builder: (context) => IconButton(
              icon: Badge(
                smallSize: 8,
                backgroundColor: AppColors.secondary,
                child: const Icon(Icons.auto_awesome, color: AppColors.primary),
              ),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
          // Notification bell
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      endDrawer: const AiAssistantDrawer(),
      body: child,
      bottomNavigationBar: CetiBottomNav(
        currentIndex: index,
        onTap: (i) => context.go(_routes[i]),
      ),
      extendBody: true,
    );
  }
}
