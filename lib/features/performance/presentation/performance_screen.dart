import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/matchmaker_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../auth/state/auth_controller.dart';
import '../data/performance_repository.dart';

final performanceRepositoryProvider = Provider((ref) => PerformanceRepository(ref.watch(apiClientProvider)));

final performanceProvider = FutureProvider.autoDispose((ref) => ref.watch(performanceRepositoryProvider).index());

class PerformanceScreen extends ConsumerWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(performanceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.performanceTitle)),
      body: AsyncValueView(
        loading: async.isLoading,
        error: async.error,
        data: async.value,
        onRetry: () => ref.invalidate(performanceProvider),
        builder: (data) {
          final stats = Map<String, dynamic>.from(data['stats'] as Map);
          final score = Map<String, dynamic>.from(data['score'] as Map);
          final tier = data['tier'] as String? ?? 'nikah_counselor';
          final accent = MatchmakerTheme.tierColors[tier] ?? MatchmakerTheme.plum;

          return RefreshIndicator(
            onRefresh: () => ref.refresh(performanceProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [accent, MatchmakerTheme.plumDark]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(MatchmakerTheme.tierBadges[tier] ?? '🥉', style: const TextStyle(fontSize: 40)),
                      if (score['overall'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(l10n.performanceQualityScore, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            Text('${score['overall']}%', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.8,
                  children: [
                    for (final entry in {
                      'Introduced': stats['introduced'],
                      'Verified': stats['verified'],
                      'Paid': stats['paid'],
                      'Clients': stats['matchmaking_clients'],
                      'Proposals': stats['proposals'],
                      'Mutual Interests': stats['mutual_interests'],
                    }.entries)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${entry.value}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                              Text(entry.key, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                if (score['overall'] != null) ...[
                  _ScoreBar(label: l10n.performanceVerificationRate, value: score['verification_rate'] as int?, color: accent),
                  _ScoreBar(label: l10n.performancePaidConversion, value: score['paid_conversion_rate'] as int?, color: accent),
                  _ScoreBar(label: l10n.performanceCompliance, value: score['compliance_rate'] as int?, color: accent),
                ],
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(l10n.performanceCommissionEarned, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('Rs. ${data['commission_earned']}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: accent)),
                      ],
                    ),
                  ),
                ),
                if (data['level_progress'] != null) ...[
                  const SizedBox(height: 16),
                  _LevelProgressCard(progress: Map<String, dynamic>.from(data['level_progress'] as Map), accent: accent, l10n: l10n),
                ] else ...[
                  const SizedBox(height: 16),
                  Card(
                    color: MatchmakerTheme.goldLight.withValues(alpha: 0.25),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(l10n.performanceMaxLevel, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                if (data['commission_rates'] != null)
                  _CommissionByLevelCard(
                    rates: Map<String, dynamic>.from(data['commission_rates'] as Map),
                    currentTier: tier,
                    l10n: l10n,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// The "X to go" breakdown from MatchmakerApplication::nextLevelProgress() —
// three concrete requirements (verified profiles, quality score, tenure),
// each showing exactly how far off the counselor still is, not just a
// single opaque percentage.
class _LevelProgressCard extends StatelessWidget {
  final Map<String, dynamic> progress;
  final Color accent;
  final AppLocalizations l10n;
  const _LevelProgressCard({required this.progress, required this.accent, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final nextLevel = progress['next_level'] as String;
    final nextLevelLabel = progress['next_level_label'] as String;
    final badge = MatchmakerTheme.tierBadges[nextLevel] ?? '🥈';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$badge ${l10n.performanceNextLevel(nextLevelLabel)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 12),
            _RequirementRow(
              label: l10n.performanceVerifiedProfiles,
              current: progress['verified']['current'] as int,
              needed: progress['verified']['needed'] as int,
              met: progress['verified']['met'] as bool,
              accent: accent,
            ),
            _RequirementRow(
              label: l10n.performanceQualityScore,
              current: progress['quality_score']['current'] as int,
              needed: progress['quality_score']['needed'] as int,
              met: progress['quality_score']['met'] as bool,
              accent: accent,
              suffix: '%',
            ),
            _RequirementRow(
              label: l10n.performanceDaysAsCounselor,
              current: progress['tenure_days']['current'] as int,
              needed: progress['tenure_days']['needed'] as int,
              met: progress['tenure_days']['met'] as bool,
              accent: accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final String label;
  final int current;
  final int needed;
  final bool met;
  final Color accent;
  final String suffix;
  const _RequirementRow({required this.label, required this.current, required this.needed, required this.met, required this.accent, this.suffix = ''});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(met ? Icons.check_circle : Icons.radio_button_unchecked, color: met ? Colors.green : Colors.grey.shade400, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Text(
            '$current / $needed$suffix',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: met ? Colors.green.shade700 : accent),
          ),
        ],
      ),
    );
  }
}

// Concrete, admin-configured commission rates for every level — reads
// straight from CommissionRule via the API (never hardcoded), so this
// always matches whatever admin has actually set, and updates the moment
// they change it.
class _CommissionByLevelCard extends StatelessWidget {
  final Map<String, dynamic> rates;
  final String currentTier;
  final AppLocalizations l10n;
  const _CommissionByLevelCard({required this.rates, required this.currentTier, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.performanceCommissionByLevel, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 4),
            Text(l10n.performanceCommissionByLevelSubtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            for (final entry in rates.entries) _CommissionLevelRow(levelKey: entry.key, data: Map<String, dynamic>.from(entry.value as Map), isCurrent: entry.key == currentTier, l10n: l10n),
          ],
        ),
      ),
    );
  }
}

class _CommissionLevelRow extends StatelessWidget {
  final String levelKey;
  final Map<String, dynamic> data;
  final bool isCurrent;
  final AppLocalizations l10n;
  const _CommissionLevelRow({required this.levelKey, required this.data, required this.isCurrent, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final color = MatchmakerTheme.tierColors[levelKey] ?? MatchmakerTheme.plum;
    final badge = MatchmakerTheme.tierBadges[levelKey] ?? '🥉';
    final label = data['label'] as String;
    final rate = data['rate'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrent ? color.withValues(alpha: 0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: isCurrent ? Border.all(color: color, width: 1.5) : null,
      ),
      child: Row(
        children: [
          Text(badge, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isCurrent ? color : null)),
                if (isCurrent)
                  Text(l10n.performanceCurrentLevelTag, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Text(rate ?? '—', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: color)),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final int? value;
  final Color color;
  const _ScoreBar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13)),
              Text('${value ?? 0}%', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: (value ?? 0) / 100, minHeight: 8, color: color, backgroundColor: color.withValues(alpha: 0.15)),
          ),
        ],
      ),
    );
  }
}
