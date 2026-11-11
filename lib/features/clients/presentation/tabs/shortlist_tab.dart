import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/data/enum_repository.dart';
import '../../../../core/theme/matchmaker_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/match_score_badge.dart';
import '../../state/client_detail_provider.dart';
import '../client_list_screen.dart';

class ShortlistTab extends ConsumerWidget {
  final int leadId;
  final Map<String, dynamic> client;
  const ShortlistTab({super.key, required this.leadId, required this.client});

  Future<void> _remove(BuildContext context, WidgetRef ref, int itemId) async {
    try {
      await ref.read(clientRepositoryProvider).removeFromShortlist(leadId, itemId);
      ref.invalidate(clientDetailProvider(leadId));
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.displayMessage)));
    }
  }

  // Lets the counselor pick WhatsApp (or any other installed share target)
  // themselves, rather than this screen hardcoding a wa.me link with no
  // destination number to send it to — the whole point is forwarding this
  // candidate's details into whatever chat with the client is already
  // open. Only matchmaker-visible, non-identity fields (no CNIC/photo/
  // contact info), same redaction NikahBrowseController applies.
  Future<void> _share(BuildContext context, Map candidate) async {
    final lines = [
      'Candidate Profile',
      if (candidate['age'] != null) 'Age: ${candidate['age']}',
      if (candidate['city'] != null) 'City: ${candidate['city']}',
      if (candidate['marital_status'] != null) 'Marital Status: ${candidate['marital_status']}',
      if (candidate['height'] != null) 'Height: ${candidate['height']}',
      if (candidate['sect'] != null) 'Sect: ${candidate['sect']}',
      if (candidate['education'] != null) 'Education: ${candidate['education']}',
      if (candidate['profession'] != null) 'Profession: ${candidate['profession']}',
      '',
      'Shared via Sallaamti Nikah Counselor',
    ];
    await SharePlus.instance.share(ShareParams(text: lines.join('\n')));
  }

  Future<void> _markFinal(BuildContext context, WidgetRef ref, int itemId, Map<String, String> methods) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<(String, String?)>(
      context: context,
      builder: (context) => _MarkFinalDialog(methods: methods),
    );
    if (result == null) return;

    try {
      await ref.read(clientRepositoryProvider).finalizeShortlistItem(leadId, itemId, method: result.$1, notes: result.$2);
      ref.invalidate(clientDetailProvider(leadId));
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.shortlistFinalized)));
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.displayMessage)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final shortlist = List<Map<String, dynamic>>.from((client['shortlist'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)));
    final enumsAsync = ref.watch(enumsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/browse-pick?forLeadId=$leadId'),
        icon: const Icon(Icons.add),
        label: Text(l10n.shortlistAdd),
        backgroundColor: MatchmakerTheme.plum,
      ),
      body: shortlist.isEmpty
          ? Center(child: Text(l10n.shortlistEmpty, style: TextStyle(color: Colors.grey.shade600)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: shortlist.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final item = shortlist[i];
                final candidate = item['candidate'] as Map?;
                final score = MatchScore.fromJson(item['match_score']);
                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(candidate != null ? '${candidate['age']} yrs, ${candidate['city'] ?? '—'}' : '—'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (item['note'] != null) Text(item['note'] as String),
                            if (score != null) ...[
                              const SizedBox(height: 4),
                              MatchScoreBadge(score: score, small: true),
                            ],
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.redAccent),
                          onPressed: () => _remove(context, ref, item['id'] as int),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: Row(
                          children: [
                            if (candidate != null)
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.share, size: 18),
                                  label: Text(l10n.shortlistShare),
                                  onPressed: () => _share(context, candidate),
                                ),
                              ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check_circle_outline, size: 18),
                                label: Text(l10n.shortlistMarkFinal),
                                style: ElevatedButton.styleFrom(backgroundColor: MatchmakerTheme.plum),
                                onPressed: enumsAsync.valueOrNull == null
                                    ? null
                                    : () => _markFinal(context, ref, item['id'] as int, enumsAsync.valueOrNull!.consentMethods),
                              ),
                            ),
                          ],
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

class _MarkFinalDialog extends StatefulWidget {
  final Map<String, String> methods;
  const _MarkFinalDialog({required this.methods});

  @override
  State<_MarkFinalDialog> createState() => _MarkFinalDialogState();
}

class _MarkFinalDialogState extends State<_MarkFinalDialog> {
  String? _method;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.shortlistMarkFinal),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.shortlistMarkFinalExplain, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _method,
            decoration: InputDecoration(labelText: l10n.consentMethodLabel),
            items: widget.methods.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
            onChanged: (v) => setState(() => _method = v),
          ),
          const SizedBox(height: 12),
          TextField(controller: _notesController, decoration: InputDecoration(labelText: l10n.clientNotesLabel), maxLines: 2),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        ElevatedButton(
          onPressed: _method == null ? null : () => Navigator.pop(context, (_method!, _notesController.text.trim().isEmpty ? null : _notesController.text.trim())),
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}
