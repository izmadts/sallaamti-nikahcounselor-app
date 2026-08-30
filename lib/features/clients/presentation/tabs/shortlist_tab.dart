import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/theme/matchmaker_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final shortlist = List<Map<String, dynamic>>.from((client['shortlist'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)));

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
                return Card(
                  child: ListTile(
                    title: Text(candidate != null ? '${candidate['age']} yrs, ${candidate['city'] ?? '—'}' : '—'),
                    subtitle: item['note'] != null ? Text(item['note'] as String) : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      onPressed: () => _remove(context, ref, item['id'] as int),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
