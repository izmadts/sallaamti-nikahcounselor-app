import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final batches = List<Map<String, dynamic>>.from((client['proposal_batches'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)));

    // "Proposal ma sirf wohi profile show gi jo pasand ki jaye gi" — the
    // client's own "interested" response (set via the member app, see
    // Api\V1\NikahMatchmakingController) across any batch/proposal is the
    // headline this tab leads with. Batch management stays below for the
    // counselor's own ongoing workflow — this is additive, not a
    // replacement for it.
    Map<String, dynamic>? finalMatch;
    for (final batch in batches) {
      final proposals = List<Map<String, dynamic>>.from((batch['proposals'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)));
      finalMatch = proposals.firstWhere((p) => p['response'] == 'interested', orElse: () => const {});
      if (finalMatch.isNotEmpty) break;
      finalMatch = null;
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _newBatch(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.batchesNew),
        backgroundColor: MatchmakerTheme.plum,
      ),
      body: batches.isEmpty
          ? Center(child: Text(l10n.batchesTitle, style: TextStyle(color: Colors.grey.shade600)))
          : Column(
              children: [
                if (finalMatch != null) _FinalMatchCard(candidate: finalMatch['candidate'] as Map?),
                Expanded(
                  child: ListView.builder(
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
                ),
              ],
            ),
    );
  }
}

class _FinalMatchCard extends StatelessWidget {
  final Map? candidate;
  const _FinalMatchCard({required this.candidate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [MatchmakerTheme.plum, MatchmakerTheme.plumLight]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.batchFinalMatchTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  candidate != null ? '${candidate!['age']} yrs, ${candidate!['city'] ?? '—'}' : '—',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
