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
              ],
            ),
          );
        },
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
