import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/data/enum_repository.dart';
import '../../../../core/theme/matchmaker_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/picker_field.dart';
import '../../state/client_detail_provider.dart';
import '../client_list_screen.dart';

class OverviewTab extends ConsumerStatefulWidget {
  final int leadId;
  final Map<String, dynamic> client;
  const OverviewTab({super.key, required this.leadId, required this.client});

  @override
  ConsumerState<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends ConsumerState<OverviewTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _notesController;
  String? _status;
  String? _source;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client['name'] as String? ?? '');
    _phoneController = TextEditingController(text: widget.client['phone'] as String? ?? '');
    _emailController = TextEditingController(text: widget.client['email'] as String? ?? '');
    _notesController = TextEditingController(text: widget.client['notes'] as String? ?? '');
    _status = widget.client['status'] as String?;
    _source = widget.client['source'] as String?;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(clientRepositoryProvider).update(widget.leadId, {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'status': _status,
        'source': _source,
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      });
      ref.invalidate(clientDetailProvider(widget.leadId));
      ref.invalidate(clientListProvider);
    } on ApiException catch (e) {
      setState(() => _error = e.displayMessage);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _generateProgressLink() async {
    try {
      final data = await ref.read(clientRepositoryProvider).regenerateProgressLink(widget.leadId);
      ref.invalidate(clientDetailProvider(widget.leadId));
      final url = data['url'] as String?;
      if (url != null) {
        await SharePlus.instance.share(ShareParams(text: url));
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.displayMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final enumsAsync = ref.watch(enumsProvider);
    final isConverted = widget.client['is_converted'] as bool? ?? false;
    final hasProgressLink = widget.client['has_progress_link'] as bool? ?? false;

    return AsyncValueView(
      loading: enumsAsync.isLoading,
      error: enumsAsync.error,
      data: enumsAsync.value,
      builder: (enums) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InlineErrorBanner(message: _error),
              if (!isConverted)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.person_add_alt),
                    label: Text(l10n.convertToProfile),
                    onPressed: () => context.push('/clients/${widget.leadId}/profile'),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(child: Text(l10n.profileAlreadyLinked)),
                        TextButton(onPressed: () => context.push('/clients/${widget.leadId}/profile'), child: Text(l10n.viewProfile)),
                      ],
                    ),
                  ),
                ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.clientNameLabel),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.errorGeneric : null,
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _phoneController, decoration: InputDecoration(labelText: l10n.clientPhoneLabel)),
              const SizedBox(height: 12),
              TextFormField(controller: _emailController, decoration: InputDecoration(labelText: l10n.clientEmailLabel)),
              const SizedBox(height: 12),
              PickerField(label: l10n.clientStatusLabel, value: _status, options: enums.leadStatuses, onChanged: (v) => setState(() => _status = v)),
              const SizedBox(height: 12),
              PickerField(label: l10n.clientSourceLabel, value: _source, options: enums.leadSources, onChanged: (v) => setState(() => _source = v)),
              const SizedBox(height: 12),
              TextFormField(controller: _notesController, decoration: InputDecoration(labelText: l10n.clientNotesLabel), maxLines: 3),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(l10n.clientSave),
              ),
              const Divider(height: 40),
              Text(l10n.progressLinkTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(l10n.progressLinkExplain, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: Icon(hasProgressLink ? Icons.share : Icons.link, color: MatchmakerTheme.plum),
                label: Text(hasProgressLink ? l10n.progressLinkShare : l10n.progressLinkGenerate),
                onPressed: _generateProgressLink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
