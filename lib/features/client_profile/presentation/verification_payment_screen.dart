import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/matchmaker_theme.dart';
import '../../../shared/widgets/picker_field.dart';
import '../../clients/state/client_detail_provider.dart';
import 'walk_in_wizard_screen.dart' show clientProfileRepositoryProvider;

// Reached from the client overview tab's verification-payment status card —
// the "come back later" counterpart to the walk-in wizard's own payment
// step (WalkInWizardScreen's _PaymentStep), for a client who skipped
// payment at registration (see that step's own "Skip for now" button) and
// is only ready to pay once a contact request is about to be shared.
class VerificationPaymentScreen extends ConsumerStatefulWidget {
  final int leadId;
  const VerificationPaymentScreen({super.key, required this.leadId});

  @override
  ConsumerState<VerificationPaymentScreen> createState() => _VerificationPaymentScreenState();
}

class _VerificationPaymentScreenState extends ConsumerState<VerificationPaymentScreen> {
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
    if (_screenshot == null) {
      setState(() => _error = 'Please attach a payment screenshot.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(clientProfileRepositoryProvider).submitPayment(
            widget.leadId,
            {'payment_method': _method, 'payment_reference': _referenceController.text.trim()},
            _screenshot!,
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
        appBar: AppBar(title: const Text('Verification Payment')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 56),
                const SizedBox(height: 16),
                const Text('Payment submitted for admin review.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'The client\'s profile goes live once this is confirmed.',
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

    return Scaffold(
      appBar: AppBar(title: const Text('Verification Payment')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(_error!, style: const TextStyle(color: Colors.redAccent))),
              PickerField(
                label: 'Payment Method',
                value: _method,
                options: const {'jazzcash': 'JazzCash', 'bank_transfer': 'Bank Transfer', 'cash': 'Cash', 'whatsapp': 'WhatsApp'},
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
                    : const Text('Submit Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
