import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/matchmaker_theme.dart';
import '../../l10n/generated/app_localizations.dart';

// Bottom-nav shell for the 4 highest-frequency destinations; everything
// else (Commission, Performance, Referral, Certification, Logout) lives
// behind "More" — keeps the primary bar to a thumb-reachable 5 items.
class AppShell extends StatelessWidget {
  final Widget child;
  final String location;

  const AppShell({super.key, required this.child, required this.location});

  int _indexFor(String location) {
    if (location.startsWith('/clients')) return 1;
    if (location.startsWith('/browse')) return 2;
    if (location.startsWith('/interests')) return 3;
    if (location.startsWith('/more') ||
        location.startsWith('/commission') ||
        location.startsWith('/performance') ||
        location.startsWith('/referral') ||
        location.startsWith('/application')) {
      return 4;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final index = _indexFor(location);

    return Scaffold(
      body: child,
      // Scaffold insets bottomNavigationBar from the system nav bar
      // automatically — unlike a fixed footer living directly in `body`
      // (see walk_in_wizard_screen.dart's own SafeArea fix), this slot is
      // always safe from being covered by it.
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: 68,
            backgroundColor: Colors.white,
            indicatorColor: MatchmakerTheme.plum.withValues(alpha: 0.14),
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => TextStyle(
                fontSize: 11.5,
                fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w500,
                color: states.contains(WidgetState.selected) ? MatchmakerTheme.plum : Colors.grey.shade600,
              ),
            ),
            iconTheme: WidgetStateProperty.resolveWith(
              (states) => IconThemeData(
                color: states.contains(WidgetState.selected) ? MatchmakerTheme.plum : Colors.grey.shade500,
                size: 24,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: index,
            elevation: 0,
            onDestinationSelected: (i) {
              switch (i) {
                case 0:
                  context.go('/dashboard');
                  break;
                case 1:
                  context.go('/clients');
                  break;
                case 2:
                  context.go('/browse');
                  break;
                case 3:
                  context.go('/interests');
                  break;
                case 4:
                  context.go('/more');
                  break;
              }
            },
            destinations: [
              NavigationDestination(icon: const Icon(Icons.dashboard_outlined), selectedIcon: const Icon(Icons.dashboard_rounded), label: l10n.navDashboard),
              NavigationDestination(icon: const Icon(Icons.people_outline), selectedIcon: const Icon(Icons.people_rounded), label: l10n.navClients),
              NavigationDestination(icon: const Icon(Icons.search_outlined), selectedIcon: const Icon(Icons.search_rounded), label: l10n.navBrowse),
              NavigationDestination(icon: const Icon(Icons.favorite_border_rounded), selectedIcon: const Icon(Icons.favorite_rounded), label: l10n.navInterests),
              NavigationDestination(icon: const Icon(Icons.more_horiz_rounded), selectedIcon: const Icon(Icons.more_horiz_rounded), label: l10n.navMore),
            ],
          ),
        ),
      ),
    );
  }
}
