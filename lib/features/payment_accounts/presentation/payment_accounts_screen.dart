import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/matchmaker_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../data/payment_accounts_repository.dart';

// A counselor relaying Sallaamti's own JazzCash/EasyPaisa/bank details to a
// client over WhatsApp/phone/in person — same numbers the client's own
// payment page shows, one tap to copy each, no hand-typing from memory.
class PaymentAccountsScreen extends ConsumerWidget {
  const PaymentAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(paymentAccountsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.paymentAccountsTitle)),
      body: AsyncValueView(
        loading: async.isLoading,
        error: async.error,
        data: async.valueOrNull,
        onRetry: () => ref.invalidate(paymentAccountsProvider),
        builder: (accounts) {
          if (accounts.isEmpty) {
            return Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(l10n.paymentAccountsEmpty, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600))));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.paymentAccountsSubtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 16),
              if ((accounts.jazzcashNumber ?? '').isNotEmpty)
                _AccountCard(
                  emoji: '📱',
                  title: 'JazzCash',
                  rows: [
                    if ((accounts.jazzcashAccountTitle ?? '').isNotEmpty) _CopyRow(label: 'Account Title', value: accounts.jazzcashAccountTitle!),
                    _CopyRow(label: 'Number', value: accounts.jazzcashNumber!),
                  ],
                ),
              if ((accounts.easypaisaNumber ?? '').isNotEmpty)
                _AccountCard(
                  emoji: '📱',
                  title: 'EasyPaisa',
                  rows: [_CopyRow(label: 'Number', value: accounts.easypaisaNumber!)],
                ),
              if ((accounts.bankAccountNumber ?? '').isNotEmpty || (accounts.bankAccountIban ?? '').isNotEmpty)
                _AccountCard(
                  emoji: '🏦',
                  title: (accounts.bankName ?? '').isNotEmpty ? accounts.bankName! : 'Bank Transfer',
                  rows: [
                    if ((accounts.bankAccountTitle ?? '').isNotEmpty) _CopyRow(label: 'Account Title', value: accounts.bankAccountTitle!),
                    if ((accounts.bankAccountNumber ?? '').isNotEmpty) _CopyRow(label: 'Account No.', value: accounts.bankAccountNumber!),
                    if ((accounts.bankAccountIban ?? '').isNotEmpty) _CopyRow(label: 'IBAN', value: accounts.bankAccountIban!),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final String emoji;
  final String title;
  final List<Widget> rows;
  const _AccountCard({required this.emoji, required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: MatchmakerTheme.plumDark)),
              ],
            ),
            const SizedBox(height: 10),
            ...rows,
          ],
        ),
      ),
    );
  }
}

class _CopyRow extends StatelessWidget {
  final String label;
  final String value;
  const _CopyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined, size: 20, color: MatchmakerTheme.plum),
            tooltip: 'Copy',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: value));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.paymentAccountsCopied), duration: const Duration(seconds: 1)));
              }
            },
          ),
        ],
      ),
    );
  }
}
