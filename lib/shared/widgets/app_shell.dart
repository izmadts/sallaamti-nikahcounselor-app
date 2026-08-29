import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
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
          NavigationDestination(icon: const Icon(Icons.dashboard_outlined), selectedIcon: const Icon(Icons.dashboard), label: l10n.navDashboard),
          NavigationDestination(icon: const Icon(Icons.people_outline), selectedIcon: const Icon(Icons.people), label: l10n.navClients),
          NavigationDestination(icon: const Icon(Icons.search_outlined), selectedIcon: const Icon(Icons.search), label: l10n.navBrowse),
          NavigationDestination(icon: const Icon(Icons.favorite_border), selectedIcon: const Icon(Icons.favorite), label: l10n.navInterests),
          NavigationDestination(icon: const Icon(Icons.more_horiz), selectedIcon: const Icon(Icons.more_horiz), label: l10n.navMore),
        ],
      ),
    );
  }
}
