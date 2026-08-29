import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/matchmaker_theme.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../features/notifications/data/notification_repository.dart';

// The shared identity bar for the app's 5 root tabs (Dashboard/Clients/
// Browse/Interests/More) — logo + wordmark on the left, a notification
// bell and the counselor's own avatar (with a small tier badge, same
// 🥉/🥈/🥇/⭐ convention as the web panel) on the right. Sub-pages (client
// detail, wizards, etc.) keep their own contextual AppBar with a specific
// title and a back button instead — this bar is deliberately only for the
// 5 "home" screens where there's nowhere to go back to.
class BrandTopBar extends ConsumerWidget implements PreferredSizeWidget {
  const BrandTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final unreadAsync = ref.watch(unreadNotificationCountProvider);
    final badgeCount = unreadAsync.valueOrNull ?? 0;
    final tierEmoji = MatchmakerTheme.tierBadges[user?.tier] ?? '🥉';

    return AppBar(
      toolbarHeight: 64,
      titleSpacing: 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/icon.png', width: 36, height: 36, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          const Flexible(
            child: Text(
              'Nikah Counselor',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: 0.2),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notifications',
                onPressed: () async {
                  await context.push('/notifications');
                  ref.invalidate(unreadNotificationCountProvider);
                },
              ),
              if (badgeCount > 0)
                Positioned(
                  right: 6,
                  top: 8,
                  child: _CountDot(count: badgeCount),
                ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.push('/performance'),
          child: Padding(
            padding: const EdgeInsets.only(right: 14, left: 2),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white24,
                  backgroundImage: (user?.avatarUrl.isNotEmpty ?? false) ? NetworkImage(user!.avatarUrl) : null,
                  child: (user?.avatarUrl.isEmpty ?? true) ? const Icon(Icons.person, color: Colors.white, size: 20) : null,
                ),
                Positioned(
                  bottom: -3,
                  right: -3,
                  child: Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Text(tierEmoji, style: const TextStyle(fontSize: 12, height: 1)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CountDot extends StatelessWidget {
  final int count;
  const _CountDot({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      decoration: BoxDecoration(
        color: MatchmakerTheme.gold,
        shape: BoxShape.circle,
        border: Border.all(color: MatchmakerTheme.plum, width: 1.5),
      ),
      child: Text(
        count > 9 ? '9+' : '$count',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, height: 1.2),
      ),
    );
  }
}
