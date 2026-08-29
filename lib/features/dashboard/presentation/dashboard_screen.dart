import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/matchmaker_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/brand_top_bar.dart';
import '../../auth/state/auth_controller.dart';
import '../data/dashboard_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(dashboardProvider);
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: const BrandTopBar(),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(dashboardProvider.future),
        child: AsyncValueView(
          loading: async.isLoading,
          error: async.error,
          data: async.value,
          onRetry: () => ref.invalidate(dashboardProvider),
          builder: (data) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (user != null)
                Text('Assalamu Alaikum, ${user.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _StatTile(label: l10n.statNewLeads, value: data.stats['new_leads'] ?? 0, color: MatchmakerTheme.plum),
                  _StatTile(label: l10n.statFollowUpsDue, value: data.stats['follow_ups_due'] ?? 0, color: Colors.orange),
                  _StatTile(label: l10n.statRegistered, value: data.stats['registered_leads'] ?? 0, color: Colors.green),
                  _StatTile(label: l10n.statActiveBatches, value: data.stats['active_batches'] ?? 0, color: MatchmakerTheme.gold),
                  _StatTile(label: l10n.statAwaitingResponse, value: data.stats['awaiting_response'] ?? 0, color: Colors.blueGrey),
                  _StatTile(label: l10n.statInterestedThisWeek, value: data.stats['interested_this_week'] ?? 0, color: Colors.teal),
                ],
              ),
              const SizedBox(height: 24),
              Text(l10n.followUpsDueTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              if (data.followUps.isEmpty)
                Text(l10n.noFollowUpsDue, style: TextStyle(color: Colors.grey.shade600))
              else
                ...data.followUps.map((lead) => Card(
                      child: ListTile(
                        title: Text(lead['name'] as String),
                        subtitle: Text(lead['status'] as String),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/clients/${lead['id']}'),
                      ),
                    )),
              const SizedBox(height: 24),
              Text(l10n.recentActivityTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              if (data.recentActivity.isEmpty)
                Text(l10n.noRecentActivity, style: TextStyle(color: Colors.grey.shade600))
              else
                ...data.recentActivity.map((event) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.history, color: MatchmakerTheme.plum),
                        title: Text(event['description'] as String),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      // Two-line labels ("Awaiting Response", "Interested This Week") could
      // overflow this fixed-aspect-ratio tile on narrower devices or larger
      // system font scales — scale the whole block down rather than clip.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$value', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
