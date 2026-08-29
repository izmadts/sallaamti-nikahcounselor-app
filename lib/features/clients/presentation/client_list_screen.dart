import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/matchmaker_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/brand_top_bar.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../auth/state/auth_controller.dart';
import '../data/client_repository.dart';

final clientRepositoryProvider = Provider((ref) => ClientRepository(ref.watch(apiClientProvider)));

final clientListFilterProvider = StateProvider.autoDispose((ref) => (status: '', search: ''));

final clientListProvider = FutureProvider.autoDispose((ref) async {
  final filter = ref.watch(clientListFilterProvider);
  final repo = ref.watch(clientRepositoryProvider);
  return repo.index(status: filter.status, search: filter.search);
});

class ClientListScreen extends ConsumerStatefulWidget {
  const ClientListScreen({super.key});

  @override
  ConsumerState<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends ConsumerState<ClientListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(clientListProvider);
    final filter = ref.watch(clientListFilterProvider);

    return Scaffold(
      appBar: const BrandTopBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/clients/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.clientsAddNew),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.clientsSearchHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
              ),
              onSubmitted: (v) => ref.read(clientListFilterProvider.notifier).state = (status: filter.status, search: v),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _StatusFilterChip(label: l10n.clientsAll, value: '', selected: filter.status, onSelect: (v) => ref.read(clientListFilterProvider.notifier).state = (status: v, search: filter.search)),
                for (final s in ['new', 'contacted', 'interested', 'registered', 'not_interested', 'closed'])
                  _StatusFilterChip(label: s, value: s, selected: filter.status, onSelect: (v) => ref.read(clientListFilterProvider.notifier).state = (status: v, search: filter.search)),
              ],
            ),
          ),
          Expanded(
            child: AsyncValueView(
              loading: async.isLoading,
              error: async.error,
              data: async.value,
              onRetry: () => ref.invalidate(clientListProvider),
              builder: (data) {
                final clients = List<Map<String, dynamic>>.from((data['clients'] as List).map((e) => Map<String, dynamic>.from(e as Map)));

                if (clients.isEmpty) {
                  return Center(child: Text(l10n.clientsEmpty, style: TextStyle(color: Colors.grey.shade600)));
                }

                return RefreshIndicator(
                  onRefresh: () => ref.refresh(clientListProvider.future),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: clients.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final c = clients[i];
                      return Card(
                        child: ListTile(
                          title: Text(c['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text((c['phone'] as String?) ?? (c['email'] as String?) ?? '—'),
                          trailing: StatusChip.forLeadStatus(c['status'] as String),
                          onTap: () => context.push('/clients/${c['id']}'),
                        ),
                      );
                    },
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

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onSelect;

  const _StatusFilterChip({required this.label, required this.value, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: MatchmakerTheme.plum,
        labelStyle: TextStyle(color: isSelected ? Colors.white : null, fontWeight: FontWeight.w600),
        onSelected: (_) => onSelect(value),
      ),
    );
  }
}
