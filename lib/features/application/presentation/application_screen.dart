import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/matchmaker_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../auth/state/auth_controller.dart';
import '../../certificate/data/certificate_repository.dart';
import '../data/application_repository.dart';

final applicationRepositoryProvider = Provider((ref) => ApplicationRepository(ref.watch(apiClientProvider)));

final applicationProvider = FutureProvider.autoDispose((ref) => ref.watch(applicationRepositoryProvider).show());

class ApplicationScreen extends ConsumerWidget {
  const ApplicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(applicationProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.applicationTitle)),
      body: AsyncValueView(
        loading: async.isLoading,
        error: async.error,
        data: async.valueOrNull,
        onRetry: () => ref.invalidate(applicationProvider),
        builder: (data) {
          final hasApplication = data['has_application'] as bool? ?? false;
          if (!hasApplication) {
            return Center(child: Text('—', style: TextStyle(color: Colors.grey.shade600)));
          }

          final steps = Map<String, dynamic>.from(data['steps'] as Map);
          final stepKeys = steps.keys.toList();
          final currentIndex = data['step_index'] as int? ?? 0;
          final accepted = data['has_accepted_agreement_and_nda'] as bool? ?? false;
          final isCertified = data['status'] == 'certified';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['status_label'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      if (data['counselor_code'] != null) ...[
                        const SizedBox(height: 4),
                        Text('${l10n.applicationCounselorCode}: ${data['counselor_code']}', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                      if (data['level_label'] != null) ...[
                        const SizedBox(height: 4),
                        Text('${l10n.applicationLevel}: ${data['level_label']}', style: TextStyle(color: MatchmakerTheme.plum, fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (int i = 0; i < stepKeys.length; i++)
                    Chip(
                      label: Text(steps[stepKeys[i]] as String, style: TextStyle(fontSize: 11, color: i <= currentIndex ? Colors.white : null)),
                      backgroundColor: i <= currentIndex ? (i == currentIndex ? MatchmakerTheme.plum : MatchmakerTheme.plum.withValues(alpha: 0.6)) : null,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: Icon(accepted ? Icons.check_circle : Icons.pending, color: accepted ? Colors.green : Colors.orange),
                  title: Text(l10n.applicationAgreementAccepted),
                  subtitle: accepted ? null : Text(l10n.applicationNotAccepted),
                ),
              ),
              if (isCertified) ...[
                const SizedBox(height: 20),
                const _CertificateCard(),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _CertificateCard extends ConsumerStatefulWidget {
  const _CertificateCard();

  @override
  ConsumerState<_CertificateCard> createState() => _CertificateCardState();
}

class _CertificateCardState extends ConsumerState<_CertificateCard> {
  bool _downloading = false;
  bool _requesting = false;
  String? _error;

  Future<void> _download() async {
    setState(() {
      _downloading = true;
      _error = null;
    });
    try {
      final file = await ref.read(certificateRepositoryProvider).downloadPdf();
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], subject: 'Sallaamti Nikah Counselor ID'));
    } catch (_) {
      if (mounted) setState(() => _error = AppLocalizations.of(context)!.errorGeneric);
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _requestDispatch() async {
    setState(() {
      _requesting = true;
      _error = null;
    });
    try {
      await ref.read(certificateRepositoryProvider).requestDispatch();
      ref.invalidate(certificateStatusProvider);
    } catch (_) {
      if (mounted) setState(() => _error = AppLocalizations.of(context)!.errorGeneric);
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(certificateStatusProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: async.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
          error: (_, _) => Text(l10n.errorGeneric, style: TextStyle(color: Colors.grey.shade600)),
          data: (status) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.badge_outlined, color: MatchmakerTheme.plum),
                    const SizedBox(width: 8),
                    Text(l10n.certificateTitle, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 12),
                if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(_error!, style: const TextStyle(color: Colors.redAccent))),
                OutlinedButton.icon(
                  onPressed: _downloading ? null : _download,
                  icon: _downloading
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.download_outlined),
                  label: Text(l10n.certificateDownload),
                ),
                const SizedBox(height: 16),
                Text(l10n.certificateCardSectionTitle, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.grey.shade700)),
                if (status.mailingAddress != null && status.mailingAddress!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(status.mailingAddress!, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                ],
                const SizedBox(height: 10),
                if (status.cardDispatchedAt != null)
                  _StatusRow(icon: Icons.local_shipping, color: Colors.green, text: l10n.certificateCardDispatched(_formatDate(status.cardDispatchedAt!)))
                else if (status.cardRequestedAt != null)
                  _StatusRow(icon: Icons.hourglass_top, color: Colors.amber.shade800, text: l10n.certificateCardRequested(_formatDate(status.cardRequestedAt!)))
                else
                  ElevatedButton.icon(
                    onPressed: _requesting ? null : _requestDispatch,
                    icon: _requesting
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.local_post_office_outlined),
                    label: Text(l10n.certificateRequestCard),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _StatusRow({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13))),
      ],
    );
  }
}
