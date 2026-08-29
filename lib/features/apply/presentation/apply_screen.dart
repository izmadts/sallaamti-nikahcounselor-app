import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/matchmaker_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/picker_field.dart';
import '../../auth/state/auth_controller.dart';
import '../data/apply_repository.dart';

final applyRepositoryProvider = Provider((ref) => ApplyRepository(ref.watch(apiClientProvider)));

final applyEnumsProvider = FutureProvider.autoDispose((ref) => ref.watch(applyRepositoryProvider).enums());

class ApplyScreen extends ConsumerStatefulWidget {
  const ApplyScreen({super.key});

  @override
  ConsumerState<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends ConsumerState<ApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _fullNameController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _ageController = TextEditingController();
  final _qualificationOtherController = TextEditingController();
  final _cnicNumberController = TextEditingController();
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();
  final _payoutTitleController = TextEditingController();
  final _payoutNumberController = TextEditingController();
  final _payoutBankController = TextEditingController();

  String? _gender;
  String? _maritalStatus;
  String? _qualification;
  String? _payoutMethod;
  bool _consentAccepted = false;
  bool _termsAccepted = false;
  final _files = <String, File>{};

  bool _submitting = false;
  bool _submitted = false;
  String? _error;

  @override
  void dispose() {
    _fullNameController.dispose();
    _guardianNameController.dispose();
    _mobileController.dispose();
    _whatsappController.dispose();
    _ageController.dispose();
    _qualificationOtherController.dispose();
    _cnicNumberController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _payoutTitleController.dispose();
    _payoutNumberController.dispose();
    _payoutBankController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String key) async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked != null) setState(() => _files[key] = File(picked.path));
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (!_consentAccepted || !_termsAccepted) {
      setState(() => _error = l10n.applyConsentRequired);
      return;
    }
    if (!_files.containsKey('selfie_photo') || !_files.containsKey('cnic_front_image') || !_files.containsKey('cnic_back_image')) {
      setState(() => _error = l10n.applyPhotosRequired);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(applyRepositoryProvider).submit({
        'full_name': _fullNameController.text.trim(),
        'guardian_name': _guardianNameController.text.trim(),
        'mobile_number': _mobileController.text.trim(),
        'whatsapp_number': _whatsappController.text.trim().isEmpty ? null : _whatsappController.text.trim(),
        'gender': _gender,
        'age': _ageController.text.trim(),
        'marital_status': _maritalStatus,
        'qualification': _qualification,
        'qualification_other': _qualificationOtherController.text.trim().isEmpty ? null : _qualificationOtherController.text.trim(),
        'cnic_number': _cnicNumberController.text.trim(),
        'area': _areaController.text.trim().isEmpty ? null : _areaController.text.trim(),
        'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        'payout_method': _payoutMethod,
        'payout_account_title': _payoutTitleController.text.trim().isEmpty ? null : _payoutTitleController.text.trim(),
        'payout_account_number': _payoutNumberController.text.trim().isEmpty ? null : _payoutNumberController.text.trim(),
        'payout_bank_name': _payoutBankController.text.trim().isEmpty ? null : _payoutBankController.text.trim(),
        'consent_accepted': true,
        'terms_accepted': true,
      }, _files);
      setState(() => _submitted = true);
    } on ApiException catch (e) {
      setState(() => _error = e.displayMessage);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final enumsAsync = ref.watch(applyEnumsProvider);

    if (_submitted) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.applyTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                Text(l10n.applySubmitted, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: () => context.pop(), child: Text(l10n.confirm)),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.applyTitle)),
      body: AsyncValueView(
        loading: enumsAsync.isLoading,
        error: enumsAsync.error,
        data: enumsAsync.value,
        onRetry: () => ref.invalidate(applyEnumsProvider),
        builder: (enums) {
          final qualifications = Map<String, String>.from(enums['qualifications'] as Map);
          final maritalStatuses = Map<String, String>.from(enums['marital_statuses'] as Map);
          final payoutMethods = Map<String, String>.from(enums['payout_methods'] as Map);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.applySubtitle, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 16),
                  InlineErrorBanner(message: _error),
                  TextFormField(controller: _fullNameController, decoration: InputDecoration(labelText: l10n.clientNameLabel), validator: _required(l10n)),
                  const SizedBox(height: 12),
                  TextFormField(controller: _guardianNameController, decoration: InputDecoration(labelText: l10n.walkInGuardianNameLabel), validator: _required(l10n)),
                  const SizedBox(height: 12),
                  TextFormField(controller: _mobileController, decoration: InputDecoration(labelText: l10n.clientPhoneLabel), keyboardType: TextInputType.phone, validator: _required(l10n)),
                  const SizedBox(height: 12),
                  TextFormField(controller: _whatsappController, decoration: InputDecoration(labelText: l10n.applyWhatsappLabel), keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  PickerField(label: l10n.clientGenderLabel, value: _gender, options: const {'male': 'Male', 'female': 'Female'}, required: true, onChanged: (v) => setState(() => _gender = v)),
                  const SizedBox(height: 12),
                  TextFormField(controller: _ageController, decoration: InputDecoration(labelText: l10n.applyAgeLabel), keyboardType: TextInputType.number, validator: _required(l10n)),
                  const SizedBox(height: 12),
                  PickerField(label: l10n.applyMaritalStatusLabel, value: _maritalStatus, options: maritalStatuses, required: true, onChanged: (v) => setState(() => _maritalStatus = v)),
                  const SizedBox(height: 12),
                  PickerField(label: l10n.applyQualificationLabel, value: _qualification, options: qualifications, required: true, onChanged: (v) => setState(() => _qualification = v)),
                  if (_qualification == 'other') ...[
                    const SizedBox(height: 12),
                    TextFormField(controller: _qualificationOtherController, decoration: InputDecoration(labelText: l10n.applyQualificationLabel)),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(controller: _cnicNumberController, decoration: InputDecoration(labelText: l10n.walkInCnicNumberLabel), validator: _required(l10n)),
                  const SizedBox(height: 16),
                  _ImageTile(label: l10n.applySelfieLabel, hasImage: _files.containsKey('selfie_photo'), onTap: () => _pickImage('selfie_photo')),
                  const SizedBox(height: 8),
                  _ImageTile(label: l10n.walkInCnicFrontLabel, hasImage: _files.containsKey('cnic_front_image'), onTap: () => _pickImage('cnic_front_image')),
                  const SizedBox(height: 8),
                  _ImageTile(label: l10n.walkInCnicBackLabel, hasImage: _files.containsKey('cnic_back_image'), onTap: () => _pickImage('cnic_back_image')),
                  const SizedBox(height: 20),
                  TextFormField(controller: _areaController, decoration: InputDecoration(labelText: l10n.applyAreaLabel)),
                  const SizedBox(height: 12),
                  TextFormField(controller: _addressController, decoration: InputDecoration(labelText: l10n.applyAddressLabel), maxLines: 2),
                  const SizedBox(height: 20),
                  Text(l10n.applyPayoutTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(l10n.applyPayoutSubtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 8),
                  PickerField(label: l10n.walkInPaymentMethodLabel, value: _payoutMethod, options: payoutMethods, onChanged: (v) => setState(() => _payoutMethod = v)),
                  if (_payoutMethod != null) ...[
                    const SizedBox(height: 12),
                    TextFormField(controller: _payoutTitleController, decoration: InputDecoration(labelText: l10n.applyPayoutTitleLabel)),
                    const SizedBox(height: 12),
                    TextFormField(controller: _payoutNumberController, decoration: InputDecoration(labelText: l10n.applyPayoutNumberLabel)),
                    if (_payoutMethod == 'bank_transfer') ...[
                      const SizedBox(height: 12),
                      TextFormField(controller: _payoutBankController, decoration: InputDecoration(labelText: l10n.applyPayoutBankLabel)),
                    ],
                  ],
                  const SizedBox(height: 20),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _consentAccepted,
                    onChanged: (v) => setState(() => _consentAccepted = v ?? false),
                    title: Text(l10n.applyConsentText, style: const TextStyle(fontSize: 13)),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _termsAccepted,
                    onChanged: (v) => setState(() => _termsAccepted = v ?? false),
                    title: Text(l10n.applyTermsText, style: const TextStyle(fontSize: 13)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(l10n.applySubmit),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String? Function(String?) _required(AppLocalizations l10n) => (v) => (v == null || v.trim().isEmpty) ? l10n.errorGeneric : null;
}

class _ImageTile extends StatelessWidget {
  final String label;
  final bool hasImage;
  final VoidCallback onTap;
  const _ImageTile({required this.label, required this.hasImage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: hasImage ? Colors.green.shade50 : Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(hasImage ? Icons.check_circle : Icons.camera_alt_outlined, color: hasImage ? Colors.green : MatchmakerTheme.plum),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
