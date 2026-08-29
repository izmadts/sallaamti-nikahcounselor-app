import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/async_value_view.dart';
import 'browse_screen.dart';

final candidateDetailProvider = FutureProvider.family.autoDispose(
  (ref, int profileId) => ref.watch(browseRepositoryProvider).show(profileId),
);

class CandidateDetailScreen extends ConsumerWidget {
  final int profileId;
  const CandidateDetailScreen({super.key, required this.profileId});

  Future<void> _requestContact(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(browseRepositoryProvider).requestContact(profileId);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.browseRequestSent)));
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.displayMessage)));
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
