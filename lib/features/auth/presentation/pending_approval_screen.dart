import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/matchmaker_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../state/auth_controller.dart';

// Shown instead of the dashboard for an account that exists (it was created
// at apply time — see NikahCounselorApplicationController::store()) but
// hasn't been granted the 'matchmaker' role yet because the application
// hasn't reached certify(). No dashboard/clients/etc. screen is reachable
// anyway (EnsureUserIsMatchmakerApi 403s them server-side) — this is simply
// somewhere to land instead of a login error, with a way to ask a human.
class PendingApprovalScreen extends ConsumerStatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  ConsumerState<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends ConsumerState<PendingApprovalScreen> {
  bool _refreshing = false;

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    await ref.read(authControllerProvider.notifier).refreshPendingStatus();
    if (mounted) setState(() => _refreshing = false);
  }

  Future<void> _contactSupport() async {
    final uri = Uri.parse('https://wa.me/923391114962');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = ref.watch(authControllerProvider).applicationStatus ?? const {};
    final statusLabel = data['status_label'] as String? ?? '';
    final steps = Map<String, dynamic>.from(data['steps'] as Map? ?? {});
    final stepKeys = steps.keys.toList();
    final currentIndex = data['step_index'] as int? ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pendingApprovalTitle)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 8),
              Icon(Icons.hourglass_top_rounded, size: 64, color: MatchmakerTheme.plum),
              const SizedBox(height: 16),
              Text(
                statusLabel.isEmpty ? l10n.pendingApprovalTitle : statusLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.pendingApprovalMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              if (stepKeys.isNotEmpty) ...[
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (int i = 0; i < stepKeys.length; i++)
                      Chip(
                        label: Text(steps[stepKeys[i]] as String, style: TextStyle(fontSize: 11, color: i <= currentIndex ? Colors.white : null)),
                        backgroundColor: i <= currentIndex ? (i == currentIndex ? MatchmakerTheme.plum : MatchmakerTheme.plum.withValues(alpha: 0.6)) : null,
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _contactSupport,
                icon: const Icon(Icons.chat),
                label: Text(l10n.pendingApprovalContactWhatsapp),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _refreshing ? null : _refresh,
                child: _refreshing
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.retry),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                child: Text(l10n.logout),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
