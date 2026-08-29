import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/locale_controller.dart';
import '../../../core/theme/matchmaker_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/state/auth_controller.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authControllerProvider).user;
    final currentLocale = ref.watch(localeControllerProvider)?.languageCode ?? 'en';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMore)),
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
          _MoreTile(icon: Icons.payments_outlined, label: l10n.commissionTitle, onTap: () => context.push('/commission')),
          _MoreTile(icon: Icons.trending_up, label: l10n.performanceTitle, onTap: () => context.push('/performance')),
          _MoreTile(icon: Icons.qr_code, label: l10n.referralTitle, onTap: () => context.push('/referral')),
          _MoreTile(icon: Icons.verified_outlined, label: l10n.applicationTitle, onTap: () => context.push('/application')),
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
  const _MoreTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color ?? MatchmakerTheme.plum),
        title: Text(label, style: TextStyle(color: color)),
        trailing: color == null ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
      ),
    );
  }
}
