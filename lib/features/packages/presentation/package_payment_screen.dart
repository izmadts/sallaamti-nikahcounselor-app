import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/matchmaker_theme.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/picker_field.dart';
import '../../clients/presentation/client_list_screen.dart';
import '../../clients/state/client_detail_provider.dart';
import '../data/packages_repository.dart';

// The counselor-side counterpart to the member app's own "hire a counselor,
// pick a package, submit payment" flow — lets a counselor do the same thing
// on behalf of a client they're assisting (walk-in or otherwise), instead
// of that client having no way to be put on a matchmaking package at all
// from this app. Submitted payment goes through the same admin review
// (Admin\LeadController::confirmPackagePayment()) every other package
// payment already does — nothing is assigned until admin confirms it.
class PackagePaymentScreen extends ConsumerStatefulWidget {
  final int leadId;
  const PackagePaymentScreen({super.key, required this.leadId});

  @override
  ConsumerState<PackagePaymentScreen> createState() => _PackagePaymentScreenState();
}

class _PackagePaymentScreenState extends ConsumerState<PackagePaymentScreen> {
  int? _selectedPackageId;
  String _method = 'jazzcash';
  final _referenceController = TextEditingController();
  File? _screenshot;
  final _picker = ImagePicker();
  bool _submitting = false;
  String? _error;
  bool _submitted = false;

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  // Gallery, not camera — a payment screenshot already exists as an image
  // from the payment app, same reasoning as the walk-in wizard's own
  // payment step.
  Future<void> _pickScreenshot() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked != null && mounted) setState(() => _screenshot = File(picked.path));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the photo gallery — check this app\'s photo permission in your phone\'s Settings, then try again.')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (_selectedPackageId == null) {
      setState(() => _error = 'Please select a package.');
      return;
    }
    if (_screenshot == null) {
      setState(() => _error = 'Please attach a payment screenshot.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(clientRepositoryProvider).submitPackagePayment(
            widget.leadId,
            nikahPackageId: _selectedPackageId!,
            paymentMethod: _method,
            paymentReference: _referenceController.text.trim().isEmpty ? null : _referenceController.text.trim(),
            screenshot: _screenshot!,
          );
      ref.invalidate(clientDetailProvider(widget.leadId));
      if (mounted) setState(() => _submitted = true);
    } on ApiException catch (e) {
      setState(() => _error = e.displayMessage);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Package Payment')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 56),
                const SizedBox(height: 16),
                const Text(
                  'Payment submitted for admin review.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'ll be notified once it\'s confirmed — the package is assigned to this client automatically at that point.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: () => context.pop(), child: const Text('Done')),
              ],
            ),
          ),
        ),
      );
    }

    final async = ref.watch(paymentInstructionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Package')),
      body: AsyncValueView(
        loading: async.isLoading,
        error: async.error,
        data: async.valueOrNull,
        onRetry: () => ref.invalidate(paymentInstructionsProvider),
        builder: (result) {
          final (packages, instructions) = result;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(_error!, style: const TextStyle(color: Colors.redAccent))),
                Text('Choose a package', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 8),
                for (final package in packages)
                  _PackageChoiceCard(
                    package: package,
                    selected: _selectedPackageId == package.id,
                    onTap: () => setState(() => _selectedPackageId = package.id),
                  ),
                const SizedBox(height: 16),
                Text('Payment details', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 8),
                _PaymentInstructionsCard(instructions: instructions),
                const SizedBox(height: 12),
                PickerField(
                  label: 'Payment Method',
                  value: _method,
                  options: const {'jazzcash': 'JazzCash', 'bank_transfer': 'Bank Transfer', 'easypaisa': 'Easypaisa'},
                  onChanged: (v) => setState(() => _method = v ?? 'jazzcash'),
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _referenceController, decoration: const InputDecoration(labelText: 'Payment Reference / Transaction ID')),
                const SizedBox(height: 12),
                ListTile(
                  tileColor: _screenshot != null ? Colors.green.shade50 : Colors.grey.shade100,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: Icon(_screenshot != null ? Icons.check_circle : Icons.image_outlined, color: _screenshot != null ? Colors.green : MatchmakerTheme.plum),
                  title: const Text('Payment Screenshot'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickScreenshot,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit for Review'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PackageChoiceCard extends StatelessWidget {
  final NikahPackageInfo package;
  final bool selected;
  final VoidCallback onTap;
  const _PackageChoiceCard({required this.package, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: selected ? MatchmakerTheme.plum : Colors.transparent, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Radio<int>(value: package.id, groupValue: selected ? package.id : null, onChanged: (_) => onTap()),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(package.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    if ((package.tagline ?? '').isNotEmpty) Text(package.tagline!, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
              Text('${package.currency ?? 'Rs.'} ${package.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentInstructionsCard extends StatelessWidget {
  final PaymentInstructions instructions;
  const _PaymentInstructionsCard({required this.instructions});

  @override
  Widget build(BuildContext context) {
    final lines = <String>[
      if ((instructions.jazzcashNumber ?? '').isNotEmpty) 'JazzCash: ${instructions.jazzcashNumber} (${instructions.jazzcashAccountTitle ?? ''})',
      if ((instructions.easypaisaNumber ?? '').isNotEmpty) 'Easypaisa: ${instructions.easypaisaNumber}',
      if ((instructions.bankName ?? '').isNotEmpty)
        'Bank: ${instructions.bankName} — ${instructions.bankAccountTitle ?? ''} — ${instructions.bankAccountNumber ?? instructions.bankAccountIban ?? ''}',
    ];

    if (lines.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(line, style: TextStyle(color: Colors.blue.shade900, fontSize: 12)),
            ),
        ],
      ),
    );
  }
}
