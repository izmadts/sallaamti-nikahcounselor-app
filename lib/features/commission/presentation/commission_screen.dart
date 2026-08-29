import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../auth/state/auth_controller.dart';
import '../data/commission_repository.dart';

final commissionRepositoryProvider = Provider((ref) => CommissionRepository(ref.watch(apiClientProvider)));

final commissionProvider = FutureProvider.autoDispose((ref) => ref.watch(commissionRepositoryProvider).index());

class CommissionScreen extends ConsumerWidget {
  const CommissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(commissionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.commissionTitle)),
      body: AsyncValueView(
        loading: async.isLoading,
        error: async.error,
        data: async.valueOrNull,
        onRetry: () => ref.invalidate(commissionProvider),
        builder: (data) {
          final entries = List<Map<String, dynamic>>.from((data['entries'] as List).map((e) => Map<String, dynamic>.from(e as Map)));
          final totals = Map<String, dynamic>.from(data['totals'] as Map);

          return RefreshIndicator(
            onRefresh: () => ref.refresh(commissionProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(child: _TotalTile(label: l10n.commissionPending, value: totals['pending'], color: Colors.amber)),
                    const SizedBox(width: 8),
                    Expanded(child: _TotalTile(label: l10n.commissionApproved, value: totals['approved'], color: Colors.blue)),
                    const SizedBox(width: 8),
                    Expanded(child: _TotalTile(label: l10n.commissionPaid, value: totals['paid'], color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 20),
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(child: Text(l10n.commissionEmpty, style: TextStyle(color: Colors.grey.shade600))),
                  )
                else
                  ...entries.map((e) => Card(
                        color: (e['is_flagged'] as bool? ?? false) ? Colors.red.shade50 : null,
                        child: ListTile(
                          title: Text('Rs. ${e['commission_amount']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(e['package'] != null ? '${e['package']} (${(e['is_renewal'] as bool) ? 'Renewal' : 'First Purchase'})' : (e['rule_type'] as String)),
                          trailing: (e['is_flagged'] as bool? ?? false)
                              ? StatusChip(label: l10n.commissionFlagged, color: Colors.red)
                              : StatusChip.forCommissionStatus(e['status'] as String),
                        ),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TotalTile extends StatelessWidget {
  final String label;
  final dynamic value;
  final Color color;
  const _TotalTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rs. $value', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: color.withValues(alpha: 0.9))),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
