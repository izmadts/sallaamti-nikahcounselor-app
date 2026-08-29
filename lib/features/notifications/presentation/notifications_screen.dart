import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/matchmaker_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../dashboard/data/dashboard_repository.dart';

// Real, in-app notifications built from data the app already has (no
// separate notifications backend yet) — follow-ups due and recent
// activity, the same two panels the Dashboard shows, just given their own
// full-screen home so the bell icon leads somewhere genuinely useful.
// Actual push delivery (an alert while the app isn't open) is a separate
// piece — see PushNotificationService.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationsTitle)),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(dashboardProvider.future),
        child: AsyncValueView(
          loading: async.isLoading,
          error: async.error,
          data: async.value,
          onRetry: () => ref.invalidate(dashboardProvider),
          builder: (data) {
            if (data.followUps.isEmpty && data.recentActivity.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Icon(Icons.notifications_none, size: 56, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(l10n.notificationsEmpty, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (data.followUps.isNotEmpty) ...[
                  Text(l10n.notificationsFollowUpsSection, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 8),
                  ...data.followUps.map((lead) => Card(
                        child: ListTile(
                          leading: const CircleAvatar(backgroundColor: Color(0xFFFFF3E0), child: Icon(Icons.schedule, color: Colors.orange)),
                          title: Text(lead['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(lead['status'] as String),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/clients/${lead['id']}'),
                        ),
                      )),
                  const SizedBox(height: 20),
                ],
                if (data.recentActivity.isNotEmpty) ...[
                  Text(l10n.notificationsActivitySection, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 8),
                  ...data.recentActivity.map((event) => Card(
                        child: ListTile(
                          leading: const CircleAvatar(backgroundColor: Color(0xFFFCE4EC), child: Icon(Icons.history, color: MatchmakerTheme.plum)),
                          title: Text(event['description'] as String),
                        ),
                      )),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
