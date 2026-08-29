import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/data/enum_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/picker_field.dart';
import 'client_list_screen.dart';

class ClientCreateScreen extends ConsumerStatefulWidget {
  const ClientCreateScreen({super.key});

  @override
  ConsumerState<ClientCreateScreen> createState() => _ClientCreateScreenState();
}

class _ClientCreateScreenState extends ConsumerState<ClientCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();
  String? _gender;
  String? _lookingFor;
  String _source = 'manual';
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final data = await ref.read(clientRepositoryProvider).create({
        'name': _nameController.text.trim(),
        'gender': _gender,
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'looking_for': _lookingFor,
        'source': _source,
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      });
      ref.invalidate(clientListProvider);
      if (!mounted) return;
      final client = Map<String, dynamic>.from(data['client'] as Map);
      context.pushReplacement('/clients/${client['id']}');
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.displayMessage);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final enumsAsync = ref.watch(enumsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.clientsAddNew)),
      body: AsyncValueView(
        loading: enumsAsync.isLoading,
        error: enumsAsync.error,
        data: enumsAsync.value,
        onRetry: () => ref.invalidate(enumsProvider),
        builder: (enums) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InlineErrorBanner(message: _error),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.clientNameLabel),
                  validator: (v) => (v == null || v.trim().isEmpty) ? l10n.errorGeneric : null,
                ),
                const SizedBox(height: 12),
                PickerField(
                  label: l10n.clientGenderLabel,
                  value: _gender,
                  options: const {'male': 'Male', 'female': 'Female'},
                  onChanged: (v) => setState(() => _gender = v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: l10n.clientPhoneLabel),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: l10n.clientEmailLabel),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                PickerField(
                  label: l10n.clientLookingForLabel,
                  value: _lookingFor,
                  options: enums.lookingFor,
                  onChanged: (v) => setState(() => _lookingFor = v),
                ),
                const SizedBox(height: 12),
                PickerField(
                  label: l10n.clientSourceLabel,
                  value: _source,
                  options: enums.leadSources,
                  required: true,
                  onChanged: (v) => setState(() => _source = v ?? 'manual'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(labelText: l10n.clientNotesLabel),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(l10n.clientSave),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
