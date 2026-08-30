import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/matchmaker_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../data/packages_repository.dart';

// The same admin-managed package catalog a client sees when choosing one —
// lets a counselor discussing options with a client (in person, over
// WhatsApp) reference the real current names/prices/limits instead of
// remembering or guessing.
class PackagesScreen extends ConsumerWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(packagesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.packagesTitle)),
      body: AsyncValueView(
        loading: async.isLoading,
        error: async.error,
        data: async.valueOrNull,
        onRetry: () => ref.invalidate(packagesProvider),
        builder: (packages) {
          if (packages.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(l10n.packagesEmpty, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.packagesSubtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 16),
              for (final package in packages) _PackageCard(package: package),
            ],
          );
        },
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final NikahPackageInfo package;
  const _PackageCard({required this.package});

  Color get _accent {
    final hex = package.color;
    if (hex == null || hex.isEmpty) return MatchmakerTheme.plum;
    try {
      final cleaned = hex.replaceAll('#', '');
      return Color(int.parse('FF$cleaned', radix: 16));
    } catch (_) {
      return MatchmakerTheme.plum;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accent = _accent;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(package.name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: accent)),
                ),
                Text(
                  '${package.currency ?? 'Rs.'} ${package.price.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ],
            ),
            if ((package.tagline ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(package.tagline!, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(package.isOneTime ? l10n.packagesOneTime : l10n.packagesDays(package.durationDays ?? 0)),
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  label: Text(
                    package.proposalLimit == null ? l10n.packagesUnlimitedProposals : l10n.packagesProposalLimit(package.proposalLimit!),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if ((package.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(package.description!, style: const TextStyle(fontSize: 13)),
            ],
            if (package.features.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...package.features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, size: 16, color: accent),
                      const SizedBox(width: 6),
                      Expanded(child: Text(f.toString(), style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
