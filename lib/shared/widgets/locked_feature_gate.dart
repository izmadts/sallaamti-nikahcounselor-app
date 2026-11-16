import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/matchmaker_theme.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../l10n/generated/app_localizations.dart';

// Trainee-access addendum (15/16 Nov 2026) — wraps a tab/screen that's only
// unlocked at a later stage (see AppUser.hasFeature/ncFeatures). A full
// matchmaker/admin never sees the locked placeholder; a trainee below the
// required stage does, with the bilingual "unlocks at your next stage"
// message instead of a broken/empty screen.
class LockedFeatureGate extends ConsumerWidget {
  final String featureKey;
  final Widget child;

  const LockedFeatureGate({super.key, required this.featureKey, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    if (user == null || user.hasFeature(featureKey)) {
      return child;
    }

    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔒', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 16),
            Text(
              l10n.featureLockedTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: MatchmakerTheme.plumDark),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.featureLockedMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
