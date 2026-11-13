import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/async_value_view.dart';
import 'browse_screen.dart';

final candidateDetailProvider = FutureProvider.family.autoDispose(
  (ref, int profileId) => ref.watch(browseRepositoryProvider).show(profileId),
);

class CandidateDetailScreen extends ConsumerWidget {
  final int profileId;
  final int? forLeadId;
  const CandidateDetailScreen({super.key, required this.profileId, this.forLeadId});

  Future<void> _requestContact(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(browseRepositoryProvider).requestContact(profileId, leadId: forLeadId);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.browseRequestSent)));
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.displayMessage)));
    }
  }

  // Mirrors the admin web panel's "📋 Copy Summary" / WhatsApp buttons on a
  // profile's show page (admin/nikah/show.blade.php) — same backend text
  // (NikahProfile::shareSummary()), same no-destination wa.me link so the
  // counselor picks whichever WhatsApp chat to paste it into.
  Future<void> _copySummary(BuildContext context, String summary) async {
    await Clipboard.setData(ClipboardData(text: summary));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied! Paste it into WhatsApp.')));
    }
  }

  Future<void> _shareOnWhatsapp(BuildContext context, String summary) async {
    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(summary)}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp.')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(candidateDetailProvider(profileId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.browseTitle)),
      body: AsyncValueView(
        loading: async.isLoading,
        error: async.error,
        data: async.valueOrNull,
        onRetry: () => ref.invalidate(candidateDetailProvider(profileId)),
        builder: (data) {
          final p = Map<String, dynamic>.from(data['profile'] as Map);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('${p['age']} yrs, ${p['city'] ?? '—'}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              _InfoRow(label: 'Marital Status', value: p['marital_status'] as String?),
              _InfoRow(label: 'Sect', value: p['sect'] as String?),
              _InfoRow(label: 'Education', value: p['education'] as String?),
              _InfoRow(label: 'Profession', value: p['profession'] as String?),
              _InfoRow(label: 'Family Type', value: p['family_type'] as String?),
              _InfoRow(label: 'Prayer Frequency', value: p['prayer_frequency'] as String?),
              if (p['about'] != null) ...[
                const SizedBox(height: 16),
                const Text('About', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(p['about'] as String),
              ],
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: const Icon(Icons.phone_forwarded_outlined),
                label: Text(l10n.browseRequestContact),
                onPressed: () => _requestContact(context, ref),
              ),
              if (p['share_summary'] != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.copy_outlined),
                      label: const Text('Copy Summary'),
                      onPressed: () => _copySummary(context, p['share_summary'] as String),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                      icon: const Icon(Icons.chat_outlined),
                      label: const Text('WhatsApp'),
                      onPressed: () => _shareOnWhatsapp(context, p['share_summary'] as String),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: TextStyle(color: Colors.grey.shade600))),
          Expanded(child: Text(value!)),
        ],
      ),
    );
  }
}
