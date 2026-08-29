import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/matchmaker_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../data/notification_repository.dart';

// A real notification inbox, not a decorative placeholder — every
// counselor-relevant event (lead assigned, consent responded, mutual
// interest, proposal response, commission earned, level promotion,
// certification) already writes here via Laravel's `database` notification
// channel; this just surfaces that same history the FCM pushes come from.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  String? _resolveInAppRoute(String? url) {
    if (url == null) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final segments = uri.pathSegments;
    final clientsIndex = segments.indexOf('clients');
    if (clientsIndex != -1 && clientsIndex + 1 < segments.length) {
      return '/clients/${segments[clientsIndex + 1]}';
    }
    if (uri.path.contains('performance')) return '/performance';
    if (uri.path.contains('commission')) return '/commission';
    return null;
  }

  IconData _iconFor(String? type) {
    return switch (type) {
      'lead_assigned' => Icons.person_add_alt_1,
      'consent_responded' => Icons.fact_check_outlined,
      'mutual_interest' => Icons.favorite,
      'proposal_responded' => Icons.mail_outline,
      'commission_earned' => Icons.payments_outlined,
      'level_promoted' => Icons.emoji_events_outlined,
      'counselor_certified' => Icons.verified_outlined,
      _ => Icons.notifications_outlined,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(notificationsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).markAllRead();
              ref.invalidate(notificationsListProvider);
            },
            child: const Text('Mark all read', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(notificationsListProvider.future),
        child: AsyncValueView(
          loading: async.isLoading,
          error: async.error,
          data: async.valueOrNull,
          onRetry: () => ref.invalidate(notificationsListProvider),
          builder: (data) {
            if (data.notifications.isEmpty) {
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

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: data.notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final n = data.notifications[index];
                return Card(
                  color: n.read ? null : MatchmakerTheme.plum.withValues(alpha: 0.06),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: n.read ? Colors.grey.shade100 : MatchmakerTheme.plum.withValues(alpha: 0.12),
                      child: Icon(_iconFor(n.type), color: n.read ? Colors.grey.shade600 : MatchmakerTheme.plum, size: 20),
                    ),
                    title: Text(n.message ?? '', style: TextStyle(fontWeight: n.read ? FontWeight.w500 : FontWeight.w700)),
                    subtitle: Text(DateFormat('d MMM, h:mm a').format(n.createdAt.toLocal())),
                    trailing: n.read ? null : const Icon(Icons.circle, size: 8, color: MatchmakerTheme.gold),
                    onTap: () async {
                      if (!n.read) {
                        await ref.read(notificationRepositoryProvider).markRead(n.id);
                        ref.invalidate(notificationsListProvider);
                      }
                      final route = _resolveInAppRoute(n.url);
                      if (route != null && context.mounted) context.push(route);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
