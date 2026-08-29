import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/data/enum_repository.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/picker_field.dart';
import '../../state/client_detail_provider.dart';
import '../client_list_screen.dart';

class ConsentTab extends ConsumerWidget {
  final int leadId;
  final Map<String, dynamic> client;
  const ConsentTab({super.key, required this.leadId, required this.client});

  Future<void> _revoke(BuildContext context, WidgetRef ref, int consentId) async {
    try {
      await ref.read(clientRepositoryProvider).revokeConsent(leadId, consentId);
      ref.invalidate(clientDetailProvider(leadId));
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.displayMessage)));
    }
  }

  Future<void> _requestConsent(BuildContext context, WidgetRef ref, Map<String, String> types) async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => _ConsentTypeDialog(title: l10n.consentRequest, types: types),
    );
    if (selected == null) return;
    try {
      await ref.read(clientRepositoryProvider).requestConsent(leadId, selected);
      ref.invalidate(clientDetailProvider(leadId));
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.displayMessage)));
    }
  }

  Future<void> _recordConsent(BuildContext context, WidgetRef ref, Map<String, String> types, Map<String, String> methods) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => _RecordConsentDialog(title: l10n.consentRecord, types: types, methods: methods),
    );
    if (result == null) return;
    try {
      await ref.read(clientRepositoryProvider).recordConsent(leadId, consentType: result.$1, method: result.$2);
      ref.invalidate(clientDetailProvider(leadId));
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.displayMessage)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final enumsAsync = ref.watch(enumsProvider);
    final consents = List<Map<String, dynamic>>.from((client['consents'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)));
    final consentRequests = List<Map<String, dynamic>>.from((client['consent_requests'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)));

    return AsyncValueView(
      loading: enumsAsync.isLoading,
      error: enumsAsync.error,
      data: enumsAsync.value,
      builder: (enums) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: () => _recordConsent(context, ref, enums.consentTypes, enums.consentMethods), child: Text(l10n.consentRecord)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(onPressed: () => _requestConsent(context, ref, enums.consentTypes), child: Text(l10n.consentRequest)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (consentRequests.where((r) => r['status'] == 'pending').isNotEmpty) ...[
            Text(l10n.consentPending, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...consentRequests.where((r) => r['status'] == 'pending').map((r) => Card(
                  color: Colors.blue.shade50,
                  child: ListTile(leading: const Icon(Icons.hourglass_empty, color: Colors.blue), title: Text(r['label'] as String)),
                )),
            const SizedBox(height: 16),
          ],
          Text(l10n.consentTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (consents.isEmpty)
            Text('—', style: TextStyle(color: Colors.grey.shade600))
          else
            ...consents.map((c) {
              final isActive = c['is_active'] as bool? ?? false;
              return Card(
                child: ListTile(
                  leading: Icon(isActive ? Icons.check_circle : Icons.cancel, color: isActive ? Colors.green : Colors.grey),
                  title: Text(c['label'] as String),
                  subtitle: Text('${c['method']} · ${isActive ? l10n.consentActive : l10n.consentRevoked}'),
                  trailing: isActive
                      ? TextButton(onPressed: () => _revoke(context, ref, c['id'] as int), child: Text(l10n.consentRevoke, style: const TextStyle(color: Colors.redAccent)))
                      : null,
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ConsentTypeDialog extends StatefulWidget {
  final String title;
  final Map<String, String> types;
  const _ConsentTypeDialog({required this.title, required this.types});

  @override
  State<_ConsentTypeDialog> createState() => _ConsentTypeDialogState();
}

class _ConsentTypeDialogState extends State<_ConsentTypeDialog> {
  String? _type;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.title),
      content: PickerField(label: l10n.consentTypeLabel, value: _type, options: widget.types, onChanged: (v) => setState(() => _type = v)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        ElevatedButton(onPressed: _type == null ? null : () => Navigator.pop(context, _type), child: Text(l10n.confirm)),
      ],
    );
  }
}

class _RecordConsentDialog extends StatefulWidget {
  final String title;
  final Map<String, String> types;
  final Map<String, String> methods;
  const _RecordConsentDialog({required this.title, required this.types, required this.methods});

  @override
  State<_RecordConsentDialog> createState() => _RecordConsentDialogState();
}

class _RecordConsentDialogState extends State<_RecordConsentDialog> {
  String? _type;
  String? _method;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PickerField(label: l10n.consentTypeLabel, value: _type, options: widget.types, onChanged: (v) => setState(() => _type = v)),
          const SizedBox(height: 12),
          PickerField(label: l10n.consentMethodLabel, value: _method, options: widget.methods, onChanged: (v) => setState(() => _method = v)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        ElevatedButton(
          onPressed: (_type == null || _method == null) ? null : () => Navigator.pop(context, (_type!, _method!)),
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}
