import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/matchmaker_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../auth/state/auth_controller.dart';
import '../data/referral_repository.dart';

final referralRepositoryProvider = Provider((ref) => ReferralRepository(ref.watch(apiClientProvider)));

final referralProvider = FutureProvider.autoDispose((ref) => ref.watch(referralRepositoryProvider).show());

class ReferralScreen extends ConsumerWidget {
  const ReferralScreen({super.key});

  Uint8List? _decodeDataUri(String? dataUri) {
    if (dataUri == null || !dataUri.contains(',')) return null;
    return base64Decode(dataUri.split(',').last);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(referralProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.referralTitle)),
      body: AsyncValueView(
        loading: async.isLoading,
        error: async.error,
        data: async.valueOrNull,
        onRetry: () => ref.invalidate(referralProvider),
        builder: (data) {
          final code = data['counselor_code'] as String?;
          final link = data['referral_link'] as String?;
          final qrBytes = _decodeDataUri(data['qr_code_data_uri'] as String?);
          final count = data['referral_count'] as int? ?? 0;

          if (code == null) {
            return Center(child: Text('—', style: TextStyle(color: Colors.grey.shade600)));
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Column(
                  children: [
                    if (qrBytes != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                        child: Image.memory(qrBytes, width: 180, height: 180),
                      ),
                    const SizedBox(height: 16),
                    Text(l10n.referralCode, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    Text(code, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: MatchmakerTheme.plum)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (link != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                  child: Text(link, style: const TextStyle(fontSize: 13)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.copy),
                        label: Text(l10n.referralCopy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: link));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.referralCopy)));
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.ios_share),
                        label: Text(l10n.referralShare),
                        onPressed: () => SharePlus.instance.share(ShareParams(text: link)),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.group_add, color: MatchmakerTheme.plum),
                  title: Text(l10n.referralCount),
                  trailing: Text('$count', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
