import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/data/enum_repository.dart';
import '../../../../core/theme/matchmaker_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/picker_field.dart';
import '../../state/client_detail_provider.dart';
import '../client_list_screen.dart';

class RequirementsTab extends ConsumerStatefulWidget {
  final int leadId;
  final Map<String, dynamic> client;
  const RequirementsTab({super.key, required this.leadId, required this.client});

  @override
  ConsumerState<RequirementsTab> createState() => _RequirementsTabState();
}

class _RequirementsTabState extends ConsumerState<RequirementsTab> {
  late List<Map<String, dynamic>> _items;
  late TextEditingController _notesController;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final requirement = widget.client['requirement'] as Map?;
    _items = requirement != null
        ? List<Map<String, dynamic>>.from((requirement['items'] as List).map((e) => Map<String, dynamic>.from(e as Map)))
        : [];
    _notesController = TextEditingController(text: requirement?['notes'] as String? ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() => _items.add({'requirement_type': '', 'requirement_value': '', 'priority': 'preferred', 'notes': null}));
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final validItems = _items.where((i) => (i['requirement_type'] as String).isNotEmpty && (i['requirement_value'] as String).isNotEmpty).toList();
      await ref.read(clientRepositoryProvider).saveRequirement(
            widget.leadId,
            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
            items: validItems,
          );
      ref.invalidate(clientDetailProvider(widget.leadId));
    } on ApiException catch (e) {
      setState(() => _error = e.displayMessage);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final enumsAsync = ref.watch(enumsProvider);

    return AsyncValueView(
      loading: enumsAsync.isLoading,
      error: enumsAsync.error,
      data: enumsAsync.value,
      builder: (enums) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InlineErrorBanner(message: _error),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(labelText: l10n.clientNotesLabel),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            for (int i = 0; i < _items.length; i++) _RequirementRow(
              item: _items[i],
              priorities: enums.requirementPriorities,
              onChanged: (updated) => setState(() => _items[i] = updated),
              onRemove: () => setState(() => _items.removeAt(i)),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.add, color: MatchmakerTheme.plum),
              label: Text(l10n.requirementsAddItem),
              onPressed: _addItem,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(l10n.clientSave),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final Map<String, String> priorities;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final VoidCallback onRemove;

  const _RequirementRow({required this.item, required this.priorities, required this.onChanged, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item['requirement_type'] as String,
                    decoration: InputDecoration(labelText: l10n.requirementTypeLabel, isDense: true),
                    onChanged: (v) => onChanged({...item, 'requirement_type': v}),
                  ),
                ),
                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: onRemove),
              ],
            ),
            TextFormField(
              initialValue: item['requirement_value'] as String,
              decoration: InputDecoration(labelText: l10n.requirementValueLabel, isDense: true),
              onChanged: (v) => onChanged({...item, 'requirement_value': v}),
            ),
            const SizedBox(height: 8),
            PickerField(
              label: l10n.requirementPriorityLabel,
              value: item['priority'] as String?,
              options: priorities,
              onChanged: (v) => onChanged({...item, 'priority': v}),
            ),
          ],
        ),
      ),
    );
  }
}
