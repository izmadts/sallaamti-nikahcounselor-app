import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/matchmaker_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/password_field.dart';
import '../../../shared/widgets/picker_field.dart';
import '../../auth/state/auth_controller.dart';
import '../data/apply_draft_store.dart';
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
  final _emailController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _ageController = TextEditingController();
  final _qualificationOtherController = TextEditingController();
  final _cnicNumberController = TextEditingController();
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();
  final _payoutTitleController = TextEditingController();
  final _payoutNumberController = TextEditingController();
  final _payoutBankController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _gender;
  String? _maritalStatus;
  String? _qualification;
  String? _payoutMethod;
  bool _consentAccepted = false;
  bool _termsAccepted = false;

  // Uploaded the moment it's picked (see _pickImage below) — this is the
  // reference sent on submit, not the raw file, so a slow connection only
  // ever risks this one small upload, not the whole typed-in form.
  String? _selfiePhotoPath;
  bool _uploadingSelfie = false;
  String? _selfieError;

  bool _submitting = false;
  bool _submitted = false;
  String? _error;

  Timer? _draftDebounce;

  @override
  void initState() {
    super.initState();
    _restoreDraft();
    for (final c in [
      _fullNameController, _guardianNameController, _mobileController, _emailController,
      _whatsappController, _ageController, _qualificationOtherController, _cnicNumberController,
      _areaController, _addressController, _payoutTitleController, _payoutNumberController,
      _payoutBankController,
    ]) {
      c.addListener(_scheduleDraftSave);
    }
  }

  // Found live (16 Nov 2026): a half-filled application lost to a dropped
  // connection, a phone call, or the app getting closed mid-form meant
  // retyping everything from scratch — this restores exactly where someone
  // left off, including an already-uploaded selfie, without them having to
  // retake or retype anything. Deliberately never restores a password.
  Future<void> _restoreDraft() async {
    final draft = await ApplyDraftStore.read();
    if (!mounted || draft == null) return;

    final fields = Map<String, dynamic>.from(draft['fields'] as Map? ?? {});
    setState(() {
      _fullNameController.text = fields['full_name'] as String? ?? '';
      _guardianNameController.text = fields['guardian_name'] as String? ?? '';
      _mobileController.text = fields['mobile_number'] as String? ?? '';
      _emailController.text = fields['email'] as String? ?? '';
      _whatsappController.text = fields['whatsapp_number'] as String? ?? '';
      _ageController.text = fields['age'] as String? ?? '';
      _qualificationOtherController.text = fields['qualification_other'] as String? ?? '';
      _cnicNumberController.text = fields['cnic_number'] as String? ?? '';
      _areaController.text = fields['area'] as String? ?? '';
      _addressController.text = fields['address'] as String? ?? '';
      _payoutTitleController.text = fields['payout_account_title'] as String? ?? '';
      _payoutNumberController.text = fields['payout_account_number'] as String? ?? '';
      _payoutBankController.text = fields['payout_bank_name'] as String? ?? '';
      _gender = fields['gender'] as String?;
      _maritalStatus = fields['marital_status'] as String?;
      _qualification = fields['qualification'] as String?;
      _payoutMethod = fields['payout_method'] as String?;
      _selfiePhotoPath = draft['selfie_photo_path'] as String?;
    });
  }

  void _scheduleDraftSave() {
    _draftDebounce?.cancel();
    _draftDebounce = Timer(const Duration(milliseconds: 500), _saveDraft);
  }

  Future<void> _saveDraft() async {
    await ApplyDraftStore.save({
      'full_name': _fullNameController.text,
      'guardian_name': _guardianNameController.text,
      'mobile_number': _mobileController.text,
      'email': _emailController.text,
      'whatsapp_number': _whatsappController.text,
      'age': _ageController.text,
      'qualification_other': _qualificationOtherController.text,
      'cnic_number': _cnicNumberController.text,
      'area': _areaController.text,
      'address': _addressController.text,
      'payout_account_title': _payoutTitleController.text,
      'payout_account_number': _payoutNumberController.text,
      'payout_bank_name': _payoutBankController.text,
      'gender': _gender,
      'marital_status': _maritalStatus,
      'qualification': _qualification,
      'payout_method': _payoutMethod,
    }, _selfiePhotoPath);
  }

  @override
  void dispose() {
    _draftDebounce?.cancel();
    _fullNameController.dispose();
    _guardianNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    _ageController.dispose();
    _qualificationOtherController.dispose();
    _cnicNumberController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _payoutTitleController.dispose();
    _payoutNumberController.dispose();
    _payoutBankController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Unguarded before: a denied camera permission (or any other
  // image_picker platform failure) threw an uncaught exception from this
  // async callback — nothing crashed visibly, the camera tile just did
  // nothing when tapped, with no way for someone unfamiliar with the app
  // to tell why they couldn't get past this required step.
  //
  // Uploads immediately (16 Nov 2026) rather than waiting for the final
  // Submit — see ApplyRepository.uploadSelfie()'s own comment for why.
  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (picked == null || !mounted) return;

      setState(() {
        _uploadingSelfie = true;
        _selfieError = null;
      });
      try {
        final path = await ref.read(applyRepositoryProvider).uploadSelfie(File(picked.path));
        if (mounted) setState(() => _selfiePhotoPath = path);
        await _saveDraft();
      } on ApiException catch (e) {
        if (mounted) setState(() => _selfieError = e.displayMessage);
      } finally {
        if (mounted) setState(() => _uploadingSelfie = false);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the camera — check that this app has camera permission in your phone\'s Settings, then try again.')),
        );
      }
    }
  }

  // Opens the real, existing public page (resources/views/nikah-counselor/
  // code-of-conduct.blade.php) — this form's own terms checkbox previously
  // had no way to actually read what it was agreeing to before ticking it.
  Future<void> _openCodeOfConduct() async {
    final uri = Uri.parse('https://sallaamti.com/nikah-counselor/code-of-conduct');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the page — check your connection and try again.')));
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (!_consentAccepted || !_termsAccepted) {
      setState(() => _error = l10n.applyConsentRequired);
      return;
    }
    if (_selfiePhotoPath == null) {
      setState(() => _error = _uploadingSelfie ? l10n.applySelfieStillUploading : l10n.applyPhotosRequired);
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
        'email': _emailController.text.trim(),
        'whatsapp_number': _whatsappController.text.trim().isEmpty ? null : _whatsappController.text.trim(),
        'gender': _gender,
        'age': _ageController.text.trim(),
        'marital_status': _maritalStatus,
        'qualification': _qualification,
        'qualification_other': _qualificationOtherController.text.trim().isEmpty ? null : _qualificationOtherController.text.trim(),
        'selfie_photo_path': _selfiePhotoPath,
        'cnic_number': _cnicNumberController.text.trim(),
        'area': _areaController.text.trim().isEmpty ? null : _areaController.text.trim(),
        'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        'payout_method': _payoutMethod,
        'payout_account_title': _payoutTitleController.text.trim().isEmpty ? null : _payoutTitleController.text.trim(),
        'payout_account_number': _payoutNumberController.text.trim().isEmpty ? null : _payoutNumberController.text.trim(),
        'payout_bank_name': _payoutBankController.text.trim().isEmpty ? null : _payoutBankController.text.trim(),
        'consent_accepted': true,
        'terms_accepted': true,
        'password': _passwordController.text,
        'password_confirmation': _confirmPasswordController.text,
      });
      await ApplyDraftStore.clear();
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
                  TextFormField(controller: _mobileController, decoration: InputDecoration(labelText: l10n.clientPhoneLabel), keyboardType: TextInputType.phone, validator: _phone(l10n)),
                  const SizedBox(height: 12),
                  // Required so certification can attach to an existing
                  // Sallaamti account (matched by this email) instead of
                  // creating a duplicate one — see the backend's own
                  // certify() comment for the bug this closes.
                  TextFormField(controller: _emailController, decoration: InputDecoration(labelText: l10n.clientEmailLabel), keyboardType: TextInputType.emailAddress, validator: _email(l10n)),
                  const SizedBox(height: 12),
                  TextFormField(controller: _whatsappController, decoration: InputDecoration(labelText: l10n.applyWhatsappLabel), keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  PickerField(label: l10n.clientGenderLabel, value: _gender, options: const {'male': 'Male', 'female': 'Female'}, required: true, onChanged: (v) { setState(() => _gender = v); _scheduleDraftSave(); }),
                  const SizedBox(height: 12),
                  TextFormField(controller: _ageController, decoration: InputDecoration(labelText: l10n.applyAgeLabel), keyboardType: TextInputType.number, validator: _age(l10n)),
                  const SizedBox(height: 12),
                  PickerField(label: l10n.applyMaritalStatusLabel, value: _maritalStatus, options: maritalStatuses, required: true, onChanged: (v) { setState(() => _maritalStatus = v); _scheduleDraftSave(); }),
                  const SizedBox(height: 12),
                  PickerField(label: l10n.applyQualificationLabel, value: _qualification, options: qualifications, required: true, onChanged: (v) { setState(() => _qualification = v); _scheduleDraftSave(); }),
                  if (_qualification == 'other') ...[
                    const SizedBox(height: 12),
                    TextFormField(controller: _qualificationOtherController, decoration: InputDecoration(labelText: l10n.applyQualificationLabel)),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(controller: _cnicNumberController, decoration: InputDecoration(labelText: l10n.walkInCnicNumberLabel)),
                  const SizedBox(height: 16),
                  _ImageTile(
                    label: l10n.applySelfieLabel,
                    hasImage: _selfiePhotoPath != null,
                    uploading: _uploadingSelfie,
                    error: _selfieError,
                    onTap: _uploadingSelfie ? null : _pickImage,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(controller: _areaController, decoration: InputDecoration(labelText: l10n.applyAreaLabel)),
                  const SizedBox(height: 12),
                  TextFormField(controller: _addressController, decoration: InputDecoration(labelText: l10n.applyAddressLabel), maxLines: 2),
                  const SizedBox(height: 20),
                  Text(l10n.applyPayoutTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(l10n.applyPayoutSubtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 8),
                  PickerField(
                    label: l10n.walkInPaymentMethodLabel,
                    value: _payoutMethod,
                    options: payoutMethods,
                    required: true,
                    onChanged: (v) { setState(() => _payoutMethod = v); _scheduleDraftSave(); },
                  ),
                  // Server-required regardless (see both NikahCounselorApplication
                  // Controllers' own validation) — these used to have no
                  // validator at all, so a counselor who skipped them got a
                  // generic, unexplained submission failure instead of being
                  // told which field was missing.
                  if (_payoutMethod != null) ...[
                    const SizedBox(height: 12),
                    TextFormField(controller: _payoutTitleController, decoration: InputDecoration(labelText: l10n.applyPayoutTitleLabel), validator: _required(l10n)),
                    const SizedBox(height: 12),
                    TextFormField(controller: _payoutNumberController, decoration: InputDecoration(labelText: l10n.applyPayoutNumberLabel), keyboardType: TextInputType.number, validator: _accountNumber(l10n)),
                    if (_payoutMethod == 'bank_transfer') ...[
                      const SizedBox(height: 12),
                      TextFormField(controller: _payoutBankController, decoration: InputDecoration(labelText: l10n.applyPayoutBankLabel), validator: _required(l10n)),
                    ],
                  ],
                  const SizedBox(height: 20),
                  Text(l10n.applyPasswordSectionTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(l10n.applyPasswordSectionSubtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 8),
                  PasswordField(
                    controller: _passwordController,
                    labelText: l10n.password,
                    validator: (v) => (v == null || v.length < 8) ? l10n.applyPasswordTooShort : null,
                  ),
                  const SizedBox(height: 12),
                  PasswordField(
                    controller: _confirmPasswordController,
                    labelText: l10n.applyConfirmPasswordLabel,
                    validator: (v) => v != _passwordController.text ? l10n.applyPasswordMismatch : null,
                  ),
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _openCodeOfConduct,
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: Text(l10n.applyReadCodeOfConduct, style: const TextStyle(fontSize: 12.5, decoration: TextDecoration.underline)),
                    ),
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

  String? Function(String?) _email(AppLocalizations l10n) => (v) {
        final value = v?.trim() ?? '';
        if (value.isEmpty) return l10n.errorGeneric;
        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) return l10n.errorGeneric;
        return null;
      };

  // Found live (16 Nov 2026): this field only ever checked "not empty" —
  // a plain string like "abc" was accepted as a mobile number. Strips
  // spaces/dashes first so "0300-1234567" and "0300 1234567" still pass.
  String? Function(String?) _phone(AppLocalizations l10n) => (v) {
        final value = v?.trim() ?? '';
        if (value.isEmpty) return l10n.errorGeneric;
        final stripped = value.replaceAll(RegExp(r'[\s-]'), '');
        if (!RegExp(r'^\+?\d{7,15}$').hasMatch(stripped)) return l10n.applyInvalidNumber;
        return null;
      };

  // Same gap as _phone above, for jazzcash/easypaisa/bank account numbers
  // — digits only, no leading '+' (these aren't phone numbers with a
  // country code).
  String? Function(String?) _accountNumber(AppLocalizations l10n) => (v) {
        final value = v?.trim() ?? '';
        if (value.isEmpty) return l10n.errorGeneric;
        if (!RegExp(r'^\d{5,34}$').hasMatch(value)) return l10n.applyInvalidNumber;
        return null;
      };

  // Same gap as _phone above — also now matches the backend's own
  // min:21/max:70 rule client-side instead of only finding out after a
  // round trip to the server.
  String? Function(String?) _age(AppLocalizations l10n) => (v) {
        final value = v?.trim() ?? '';
        if (value.isEmpty) return l10n.errorGeneric;
        final age = int.tryParse(value);
        if (age == null || age < 21 || age > 70) return l10n.applyInvalidNumber;
        return null;
      };
}

class _ImageTile extends StatelessWidget {
  final String label;
  final bool hasImage;
  final bool uploading;
  final String? error;
  final VoidCallback? onTap;
  const _ImageTile({required this.label, required this.hasImage, this.uploading = false, this.error, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          tileColor: hasImage ? Colors.green.shade50 : Colors.grey.shade100,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: uploading
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(hasImage ? Icons.check_circle : Icons.camera_alt_outlined, color: hasImage ? Colors.green : MatchmakerTheme.plum),
          title: Text(uploading ? 'Uploading…' : label),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12.5)),
          ),
      ],
    );
  }
}
