import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/matchmaker_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/brand_top_bar.dart';
import '../../../shared/widgets/match_score_badge.dart';
import '../../auth/state/auth_controller.dart';
import '../../clients/presentation/client_list_screen.dart';
import '../../clients/state/client_detail_provider.dart';
import '../data/browse_repository.dart';

final browseRepositoryProvider = Provider((ref) => BrowseRepository(ref.watch(apiClientProvider)));

final browseFilterProvider = StateProvider.autoDispose<Map<String, String>>((ref) => {});

// Keyed by forLeadId so a plain browse (null) and a pick-mode browse for a
// specific client never share a cached result — the server includes a
// match_score per candidate only when a lead_id is sent.
final browseListProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, int?>((ref, forLeadId) {
  final filters = ref.watch(browseFilterProvider);
  final query = {...filters, if (forLeadId != null) 'lead_id': forLeadId.toString()};
  return ref.watch(browseRepositoryProvider).index(query);
});

// When forLeadId is set, each card shows an "add to shortlist" (or, if
// forBatchId is also set, "add to batch") action instead of just browsing —
// same screen, two purposes, since the underlying candidate list and
// filters are identical either way.
class BrowseScreen extends ConsumerWidget {
  final int? forLeadId;
  final int? forBatchId;
  const BrowseScreen({super.key, this.forLeadId, this.forBatchId});

  Future<void> _addToShortlist(BuildContext context, WidgetRef ref, int profileId) async {
    try {
      await ref.read(clientRepositoryProvider).addToShortlist(forLeadId!, profileId);
      ref.invalidate(clientDetailProvider(forLeadId!));
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.shortlistAdd)));
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.displayMessage)));
    }
  }

  Future<void> _addToBatch(BuildContext context, WidgetRef ref, int profileId) async {
    try {
      await ref.read(clientRepositoryProvider).addProposal(forLeadId!, forBatchId!, profileId);
      ref.invalidate(clientDetailProvider(forLeadId!));
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.batchAddCandidate)));
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.displayMessage)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(browseListProvider(forLeadId));
    final filters = ref.watch(browseFilterProvider);
    final isPickMode = forLeadId != null;

    return Scaffold(
      // Pick mode is a focused sub-task (choosing a candidate for a
      // specific batch), reached by pushing over whatever screen the
      // counselor was already on — a back button and specific title fit
      // better there than the shared brand bar the 4 other root tabs use.
      appBar: isPickMode ? AppBar(title: Text(l10n.browseTitle)) : const BrandTopBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: filters['gender'],
                    decoration: InputDecoration(labelText: l10n.browseFilterGender, isDense: true),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                    ],
                    onChanged: (v) => ref.read(browseFilterProvider.notifier).state = {...filters, if (v != null) 'gender': v},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: l10n.browseFilterCity, isDense: true),
                    onFieldSubmitted: (v) => ref.read(browseFilterProvider.notifier).state = {...filters, 'city': v},
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AsyncValueView(
              loading: async.isLoading,
              error: async.error,
              data: async.valueOrNull,
              onRetry: () => ref.invalidate(browseListProvider(forLeadId)),
              builder: (data) {
                final profiles = List<Map<String, dynamic>>.from((data['profiles'] as List).map((e) => Map<String, dynamic>.from(e as Map)));
                if (profiles.isEmpty) {
                  return Center(child: Text(l10n.browseEmpty, style: TextStyle(color: Colors.grey.shade600)));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: profiles.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final p = profiles[i];
                    final score = MatchScore.fromJson(p['match_score']);
                    return Card(
                      child: ListTile(
                        title: Text('${p['age']} yrs, ${p['city'] ?? '—'}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text([p['sect'], p['profession']].where((e) => e != null).join(' · ')),
                            if (score != null) ...[
                              const SizedBox(height: 4),
                              MatchScoreBadge(score: score, small: true),
                            ],
                          ],
                        ),
                        trailing: isPickMode
                            ? IconButton(
                                icon: const Icon(Icons.add_circle, color: MatchmakerTheme.plum),
                                onPressed: () => forBatchId != null ? _addToBatch(context, ref, p['id'] as int) : _addToShortlist(context, ref, p['id'] as int),
                              )
                            : IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: () => context.push('/browse/${p['id']}'),
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
