import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/matchmaker_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/brand_top_bar.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../auth/state/auth_controller.dart';
import '../data/client_repository.dart';

final clientRepositoryProvider = Provider((ref) => ClientRepository(ref.watch(apiClientProvider)));

final clientListFilterProvider = StateProvider.autoDispose((ref) => (status: '', search: ''));

class ClientListState {
  final List<Map<String, dynamic>> clients;
  final int page;
  final int lastPage;
  final bool loading;
  final bool loadingMore;
  final Object? error;

  const ClientListState({
    this.clients = const [],
    this.page = 1,
    this.lastPage = 1,
    this.loading = true,
    this.loadingMore = false,
    this.error,
  });

  bool get hasMore => page < lastPage;

  ClientListState copyWith({
    List<Map<String, dynamic>>? clients,
    int? page,
    int? lastPage,
    bool? loading,
    bool? loadingMore,
    Object? error,
  }) =>
      ClientListState(
        clients: clients ?? this.clients,
        page: page ?? this.page,
        lastPage: lastPage ?? this.lastPage,
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        error: error,
      );
}

// A counselor's lead list is paginated server-side (15/page — see
// Matchmaker\ClientController::index()), but the previous version of this
// screen never requested page 2+, so once a counselor passed 15 leads the
// rest were simply never fetched — it looked like the list "stopped
// scrolling" once the visible 15 ran out, when really there was nothing
// more on screen to scroll to.
class ClientListController extends StateNotifier<ClientListState> {
  final ClientRepository _repo;
  final ({String status, String search}) _filter;

  ClientListController(this._repo, this._filter) : super(const ClientListState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final data = await _repo.index(status: _filter.status, search: _filter.search, page: 1);
      state = ClientListState(
        clients: List<Map<String, dynamic>>.from((data['clients'] as List).map((e) => Map<String, dynamic>.from(e as Map))),
        page: data['current_page'] as int? ?? 1,
        lastPage: data['last_page'] as int? ?? 1,
        loading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(loading: false, error: e);
    } catch (e) {
      state = state.copyWith(loading: false, error: e);
    }
  }

  Future<void> refresh() => _load();

  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasMore) return;
    state = state.copyWith(loadingMore: true);
    try {
      final nextPage = state.page + 1;
      final data = await _repo.index(status: _filter.status, search: _filter.search, page: nextPage);
      final more = List<Map<String, dynamic>>.from((data['clients'] as List).map((e) => Map<String, dynamic>.from(e as Map)));
      state = state.copyWith(
        clients: [...state.clients, ...more],
        page: data['current_page'] as int? ?? nextPage,
        lastPage: data['last_page'] as int? ?? state.lastPage,
        loadingMore: false,
      );
    } on ApiException {
      // A failed "load more" shouldn't blank out the list already on
      // screen — just stop trying; the counselor can retry by scrolling
      // again, which calls loadMore() once more.
      state = state.copyWith(loadingMore: false);
    } catch (_) {
      state = state.copyWith(loadingMore: false);
    }
  }
}

final clientListProvider = StateNotifierProvider.autoDispose<ClientListController, ClientListState>((ref) {
  final filter = ref.watch(clientListFilterProvider);
  return ClientListController(ref.watch(clientRepositoryProvider), filter);
});

class ClientListScreen extends ConsumerStatefulWidget {
  const ClientListScreen({super.key});

  @override
  ConsumerState<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends ConsumerState<ClientListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(clientListProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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
              loading: async.loading,
              error: async.error,
              data: async.clients.isEmpty && (async.loading || async.error != null) ? null : async,
              onRetry: () => ref.invalidate(clientListProvider),
              builder: (data) {
                final clients = data.clients;

                if (clients.isEmpty) {
                  return Center(child: Text(l10n.clientsEmpty, style: TextStyle(color: Colors.grey.shade600)));
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(clientListProvider.notifier).refresh(),
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: clients.length + (data.hasMore ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      if (i >= clients.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: MatchmakerTheme.plum)),
                        );
                      }

                      final c = clients[i];
                      final unread = c['unread_message_count'] as int? ?? 0;
                      final profileId = c['nikah_profile_id'] as int?;
                      return Card(
                        child: ListTile(
                          leading: GenderBadge(gender: c['gender'] as String?),
                          title: Text(c['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text([
                            (c['phone'] as String?) ?? (c['email'] as String?) ?? '—',
                            if (profileId != null) 'Profile #$profileId',
                          ].join(' · ')),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (unread > 0) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: MatchmakerTheme.plum, borderRadius: BorderRadius.circular(10)),
                                  child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                                const SizedBox(width: 6),
                              ],
                              StatusChip.forLeadStatus(c['status'] as String),
                            ],
                          ),
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

// Lets the counselor tell cards apart at a glance in a long list, same
// purpose as the Profile # shown right next to it — gender alone, not a
// photo (matchmaker browse/clients views never show identity-revealing
// fields).
class GenderBadge extends StatelessWidget {
  final String? gender;
  const GenderBadge({super.key, required this.gender});

  @override
  Widget build(BuildContext context) {
    final isMale = gender == 'male';
    final isFemale = gender == 'female';
    final color = isMale ? Colors.blue.shade600 : (isFemale ? MatchmakerTheme.plum : Colors.grey.shade400);
    final icon = isMale ? Icons.male : (isFemale ? Icons.female : Icons.person_outline);

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.15),
      child: Icon(icon, color: color),
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
