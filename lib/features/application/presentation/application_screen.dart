import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/matchmaker_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../auth/state/auth_controller.dart';
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
        data: async.value,
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
            ],
          );
        },
      ),
    );
  }
}
