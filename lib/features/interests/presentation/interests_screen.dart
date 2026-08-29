import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../auth/state/auth_controller.dart';
import '../data/interest_repository.dart';

final interestRepositoryProvider = Provider((ref) => InterestRepository(ref.watch(apiClientProvider)));

final interestsProvider = FutureProvider.autoDispose((ref) => ref.watch(interestRepositoryProvider).index());

class InterestsScreen extends ConsumerWidget {
  const InterestsScreen({super.key});

  Future<void> _respond(BuildContext context, WidgetRef ref, int interestId, bool accept) async {
    try {
      if (accept) {
        await ref.read(interestRepositoryProvider).accept(interestId);
      } else {
        await ref.read(interestRepositoryProvider).decline(interestId);
      }
      ref.invalidate(interestsProvider);
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.displayMessage)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(interestsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.interestsTitle)),
      body: AsyncValueView(
        loading: async.isLoading,
        error: async.error,
        data: async.value,
        onRetry: () => ref.invalidate(interestsProvider),
        builder: (data) {
          final interests = List<Map<String, dynamic>>.from((data['interests'] as List).map((e) => Map<String, dynamic>.from(e as Map)));
          if (interests.isEmpty) {
            return Center(child: Text(l10n.interestsEmpty, style: TextStyle(color: Colors.grey.shade600)));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(interestsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: interests.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final interest = interests[i];
                final receiver = interest['receiver'] as Map;
                final sender = interest['sender'] as Map;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('${receiver['name']} received interest from:', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('${sender['age']} yrs, ${sender['city'] ?? '—'}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _respond(context, ref, interest['id'] as int, false),
                                child: Text(l10n.interestDecline),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _respond(context, ref, interest['id'] as int, true),
                                child: Text(l10n.interestAccept),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
