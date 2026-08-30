import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/theme/matchmaker_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../state/client_detail_provider.dart';
import '../client_list_screen.dart';

class BatchesTab extends ConsumerWidget {
  final int leadId;
  final Map<String, dynamic> client;
  const BatchesTab({super.key, required this.leadId, required this.client});

  Future<void> _newBatch(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(clientRepositoryProvider).createBatch(leadId);
      ref.invalidate(clientDetailProvider(leadId));
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.displayMessage)));
    }
  }

  Future<void> _sendBatch(BuildContext context, WidgetRef ref, int batchId) async {
    try {
      await ref.read(clientRepositoryProvider).sendBatch(leadId, batchId);
      ref.invalidate(clientDetailProvider(leadId));
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.displayMessage)));
    }
  }

  Future<void> _shareOrRegenerateLink(BuildContext context, WidgetRef ref, int batchId, int proposalId, String? existingUrl) async {
    if (existingUrl != null) {
      await SharePlus.instance.share(ShareParams(text: existingUrl));
      return;
    }
    try {
      final data = await ref.read(clientRepositoryProvider).regenerateProposalLink(leadId, batchId, proposalId);
      ref.invalidate(clientDetailProvider(leadId));
      final url = data['url'] as String?;
      if (url != null) await SharePlus.instance.share(ShareParams(text: url));
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.displayMessage)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final batches = List<Map<String, dynamic>>.from((client['proposal_batches'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _newBatch(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.batchesNew),
        backgroundColor: MatchmakerTheme.plum,
      ),
      body: batches.isEmpty
          ? Center(child: Text(l10n.batchesTitle, style: TextStyle(color: Colors.grey.shade600)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: batches.length,
              itemBuilder: (context, i) {
                final batch = batches[i];
                final proposals = List<Map<String, dynamic>>.from((batch['proposals'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)));
                final isDraft = batch['status'] == 'draft';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Text('Batch #${batch['batch_number']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                            const Spacer(),
                            StatusChip(
                              label: isDraft ? l10n.batchStatusDraft : l10n.batchStatusSent,
                              color: isDraft ? Colors.grey : Colors.green,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        for (final p in proposals)
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(p['candidate'] != null ? '${p['candidate']['age']} yrs, ${p['candidate']['city'] ?? '—'}' : '—'),
                            subtitle: Text((p['response'] as String?) ?? (p['status'] as String? ?? '—')),
                            trailing: p['status'] == 'sent' || p['status'] == 'responded'
                                ? IconButton(
                                    icon: const Icon(Icons.ios_share, size: 20),
                                    onPressed: () => _shareOrRegenerateLink(context, ref, batch['id'] as int, p['id'] as int, p['share_url'] as String?),
                                  )
                                : null,
                          ),
                        if (isDraft) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => context.push('/browse-pick?forLeadId=$leadId&forBatchId=${batch['id']}'),
                                  child: Text(l10n.batchAddCandidate),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: proposals.isEmpty ? null : () => _sendBatch(context, ref, batch['id'] as int),
                                  child: Text(l10n.batchSend),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
