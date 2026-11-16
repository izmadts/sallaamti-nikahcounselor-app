import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/locale_controller.dart';
import '../../../core/theme/matchmaker_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/brand_top_bar.dart';
import '../../auth/state/auth_controller.dart';

void _showLockedMessage(BuildContext context, AppLocalizations l10n) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.featureLockedMessage)));
}

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authControllerProvider).user;
    final currentLocale = ref.watch(localeControllerProvider)?.languageCode ?? 'en';

    return Scaffold(
      appBar: const BrandTopBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          _MoreTile(
            icon: Icons.language,
            label: currentLocale == 'en' ? l10n.urdu : l10n.english,
            onTap: () => ref.read(localeControllerProvider.notifier).choose(currentLocale == 'en' ? 'ur' : 'en'),
          ),
          _MoreTile(icon: Icons.card_giftcard_outlined, label: l10n.packagesTitle, onTap: () => context.push('/packages')),
          _MoreTile(icon: Icons.payments_outlined, label: l10n.commissionTitle, onTap: () => context.push('/commission')),
          _MoreTile(icon: Icons.trending_up, label: l10n.performanceTitle, onTap: () => context.push('/performance')),
          // Referral link is certified-only (trainee-access addendum) — kept
          // visible but greyed/intercepted below Certified, same spirit as
          // the Browse bottom-nav destination.
          _MoreTile(
            icon: Icons.qr_code,
            label: (user?.hasFeature('referral') ?? true) ? l10n.referralTitle : '🔒 ${l10n.referralTitle}',
            locked: !(user?.hasFeature('referral') ?? true),
            onTap: (user?.hasFeature('referral') ?? true) ? () => context.push('/referral') : () => _showLockedMessage(context, l10n),
          ),
          _MoreTile(icon: Icons.verified_outlined, label: l10n.applicationTitle, onTap: () => context.push('/application')),
          _MoreTile(icon: Icons.menu_book_outlined, label: l10n.guideTitle, onTap: () => context.push('/guide')),
          // Always reachable, at every stage — "re-read the guide and see
          // your score any time" (owner's explicit ask).
          _MoreTile(icon: Icons.school_outlined, label: l10n.moreTrainingGuide, onTap: () => context.push('/training-guide')),
          _MoreTile(icon: Icons.account_balance_outlined, label: l10n.paymentAccountsTitle, onTap: () => context.push('/payment-accounts')),
          const Divider(height: 32),
          _MoreTile(
            icon: Icons.logout,
            label: l10n.logout,
            color: Colors.redAccent,
            onTap: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool locked;
  const _MoreTile({required this.icon, required this.label, required this.onTap, this.color, this.locked = false});

  @override
  Widget build(BuildContext context) {
    final lockedColor = locked ? Colors.grey.shade400 : null;
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color ?? lockedColor ?? MatchmakerTheme.plum),
        title: Text(label, style: TextStyle(color: color ?? lockedColor)),
        trailing: color == null ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
      ),
    );
  }
}
