import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/data/enum_repository.dart';
import '../../../../core/theme/matchmaker_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/set_login_password_flow.dart';
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
  String? _gender;
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
    _gender = widget.client['gender'] as String?;
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
        'gender': _gender,
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'status': _status,
        'source': _source,
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      });
      ref.invalidate(clientDetailProvider(widget.leadId));
      ref.invalidate(clientListProvider);
      // Same gap as RequirementsTab — a save that ends in silence looks
      // identical to one that silently did nothing.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.clientSaved)));
      }
    } on ApiException catch (e) {
      setState(() => _error = e.displayMessage);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openSetPasswordDialog() => showSetLoginPasswordFlow(context, ref, widget.leadId);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final enumsAsync = ref.watch(enumsProvider);
    final isConverted = widget.client['is_converted'] as bool? ?? false;
    final packageId = widget.client['nikah_package_id'];
    final packageName = widget.client['package_name'] as String?;
    final packagePaymentStatus = widget.client['package_payment_status'] as String?;
    final packageRejectionReason = widget.client['package_payment_rejection_reason'] as String?;

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
              _PackageStatusCard(
                leadId: widget.leadId,
                packageId: packageId,
                packageName: packageName,
                paymentStatus: packagePaymentStatus,
                rejectionReason: packageRejectionReason,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.clientNameLabel),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.errorGeneric : null,
              ),
              const SizedBox(height: 12),
              // Was collected at client creation but never shown/editable
              // here — also what Browse's pick-mode now defaults its
              // gender filter against (opposite gender), so a client with
              // no gender recorded gets no automatic narrowing there either.
              PickerField(
                label: l10n.clientGenderLabel,
                value: _gender,
                options: const {'male': 'Male', 'female': 'Female'},
                onChanged: (v) => setState(() => _gender = v),
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
              if (isConverted) ...[
                const Divider(height: 40),
                Text(l10n.loginPasswordTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(l10n.loginPasswordExplain, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: Icon(Icons.password, color: MatchmakerTheme.plum),
                  label: Text(l10n.loginPasswordSet),
                  onPressed: _openSetPasswordDialog,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Matchmaking package was never shown anywhere on a client's own page
// before this — a counselor had no way to see, let alone set, which
// package (if any) a client was on, or whether a submitted payment was
// still awaiting admin review.
class _PackageStatusCard extends StatelessWidget {
  final int leadId;
  final dynamic packageId;
  final String? packageName;
  final String? paymentStatus;
  final String? rejectionReason;

  const _PackageStatusCard({
    required this.leadId,
    required this.packageId,
    required this.packageName,
    required this.paymentStatus,
    required this.rejectionReason,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color, title, subtitle) = switch ((packageId, paymentStatus)) {
      (final id, _) when id != null => (
          Icons.workspace_premium,
          Colors.green,
          packageName ?? 'Matchmaking package active',
          'Active package',
        ),
      (_, 'submitted') => (Icons.hourglass_top, Colors.amber, 'Package payment under review', 'Admin will confirm shortly'),
      (_, 'rejected') => (Icons.error_outline, Colors.red, 'Package payment rejected', rejectionReason ?? 'Submit a new payment'),
      _ => (Icons.add_shopping_cart, Colors.grey, 'No matchmaking package yet', 'Select a package for this client'),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: color.withValues(alpha: 0.9))),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
            if (packageId == null && paymentStatus != 'submitted')
              TextButton(
                onPressed: () => context.push('/clients/$leadId/package-payment'),
                child: Text(paymentStatus == 'rejected' ? 'Retry' : 'Select'),
              ),
          ],
        ),
      ),
    );
  }
}
