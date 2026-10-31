import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/locale_controller.dart';
import '../../../core/theme/matchmaker_theme.dart';
import '../state/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decideRoute();
  }

  // Awaits both restores explicitly instead of reacting to build-time
  // provider snapshots — the previous version read `locale` via ref.watch()
  // on the very first frame, before the async secure-storage read behind it
  // had any chance to finish, so it reliably looked null and sent every
  // app open (not just first install) to the language picker.
  Future<void> _decideRoute() async {
    final locale = await ref.read(localeControllerProvider.notifier).ensureRestored();
    if (!mounted) return;

    if (locale == null) {
      context.go('/language');
      return;
    }

    final auth = await ref.read(authControllerProvider.notifier).ensureRestored();
    if (!mounted) return;

    if (auth.status == AuthStatus.authenticated) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MatchmakerTheme.plumDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: 'Sallaamti Nikah Counselor',
              child: Image.asset('assets/icon.png', width: 200),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
