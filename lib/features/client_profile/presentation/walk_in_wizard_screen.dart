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
import '../../../shared/widgets/set_login_password_flow.dart';
import '../../auth/state/auth_controller.dart';
import '../../clients/state/client_detail_provider.dart';
import '../data/client_profile_repository.dart';

final clientProfileRepositoryProvider = Provider((ref) => ClientProfileRepository(ref.watch(apiClientProvider)));

final clientProfileProvider = FutureProvider.family.autoDispose(
  (ref, int leadId) => ref.watch(clientProfileRepositoryProvider).show(leadId),
);

class WalkInWizardScreen extends ConsumerStatefulWidget {
  final int leadId;
  const WalkInWizardScreen({super.key, required this.leadId});

  @override
  ConsumerState<WalkInWizardScreen> createState() => _WalkInWizardScreenState();
}

class _WalkInWizardScreenState extends ConsumerState<WalkInWizardScreen> {
  final _pageController = PageController();
  int _page = 0;
  bool _submitting = false;
  String? _error;
  bool _hasProfile = false;

  // Field state, populated once from the loaded profile / prefill.
  final _fields = <String, dynamic>{};

  bool _initialized = false;

  void _initFromData(Map<String, dynamic> data) {
    if (_initialized) return;
    _initialized = true;
    _hasProfile = data['has_profile'] as bool;

    if (_hasProfile) {
      final profile = Map<String, dynamic>.from(data['profile'] as Map);
      _fields.addAll({
        'city': profile['city'],
        'marital_status': profile['marital_status'],
        'height': profile['height'],
        'guardian_name': profile['guardian_name'],
        'guardian_contact': profile['guardian_contact'],
        'guardian_relation': profile['guardian_relation'],
        'family_type': profile['family_type'],
        'sect': profile['sect'],
        'prayer_frequency': profile['prayer_frequency'],
        'hijab_or_beard': profile['hijab_or_beard'],
        'diet': profile['diet'],
        'smokes': profile['smokes'],
        'about': profile['about'],
        'expectations': profile['expectations'],
        'education': profile['education'],
        'profession': profile['profession'],
      });
    } else {
      final prefill = Map<String, dynamic>.from(data['prefill'] as Map);
      _fields['gender'] = prefill['gender'];
      if (prefill['email'] != null) _fields['identifier'] = prefill['email'];
      if (prefill['phone'] != null) _fields['identifier'] ??= prefill['phone'];
    }
  }

  Future<bool> _saveStep(Map<String, dynamic> stepFields) async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    final payload = <String, dynamic>{...stepFields};
    if (!_hasProfile) {
      payload['visibility'] = 'matchmaker_assisted';
    }

    try {
      await ref.read(clientProfileRepositoryProvider).store(widget.leadId, payload);
      _hasProfile = true;
      ref.invalidate(clientDetailProvider(widget.leadId));
      return true;
    } on ApiException catch (e) {
      setState(() => _error = e.displayMessage);
      return false;
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _next() {
    if (_page < 4) {
      setState(() => _page++);
      _pageController.animateToPage(_page, duration: const Duration(milliseconds: 250), curve: Curves.ease);
    } else {
      if (mounted) context.pop();
    }
  }

  void _back() {
    if (_page > 0) {
      setState(() => _page--);
      _pageController.animateToPage(_page, duration: const Duration(milliseconds: 250), curve: Curves.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(clientProfileProvider(widget.leadId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.walkInWizardTitle)),
      // The Save & Continue button lives directly in `body`, not
      // `bottomNavigationBar` — Scaffold only insets that latter slot from
      // the system nav bar automatically, so without SafeArea here the
      // button sits underneath on-screen (3-button) navigation.
      body: SafeArea(
        child: AsyncValueView(
        loading: async.isLoading,
        error: async.error,
        data: async.valueOrNull,
        onRetry: () => ref.invalidate(clientProfileProvider(widget.leadId)),
        builder: (data) {
          _initFromData(data);
          return Column(
            children: [
              LinearProgressIndicator(value: (_page + 1) / 5, color: MatchmakerTheme.plum),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _BasicStep(fields: _fields, requireIdentifier: !_hasProfile),
                    _FamilyStep(fields: _fields),
                    _DeenStep(fields: _fields),
                    _AboutStep(fields: _fields),
                    _PaymentStep(leadId: widget.leadId),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                      ),
                    Row(
                      children: [
                        if (_page > 0)
                          Expanded(child: OutlinedButton(onPressed: _submitting ? null : _back, child: const Icon(Icons.arrow_back))),
                        if (_page > 0) const SizedBox(width: 8),
                        if (_page < 4)
                          Expanded(
                            flex: 3,
                            child: ElevatedButton(
                              onPressed: _submitting
                                  ? null
                                  : () async {
                                      final validationError = _validateStep(_page);
                                      if (validationError != null) {
                                        setState(() => _error = validationError);
                                        return;
                                      }
                                      final stepFields = _stepFieldsFor(_page);
                                      final ok = await _saveStep(stepFields);
                                      if (ok) _next();
                                    },
                              child: _submitting
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text(l10n.walkInSaveStep),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        ),
      ),
    );
  }

  // Marital status of anything but "never married" makes has_children and
  // living_situation required on the backend (ValidatesNikahProfile's
  // required_if rules) — but that rule only fires for keys actually present
  // in the request, and postMultipart drops null fields entirely, so a
  // skipped selection here would otherwise save silently instead of erroring.
  bool get _needsFamilyDetails {
    final status = _fields['marital_status'] as String?;
    return status != null && status != 'never_married';
  }

  String? _validateStep(int page) {
    if (page == 1 && _needsFamilyDetails) {
      if (_fields['has_children'] == null) return 'Please let us know if the client has children.';
      if (_fields['living_situation'] == null) return 'Please let us know who the client currently lives with.';
    }
    return null;
  }

  Map<String, dynamic> _stepFieldsFor(int page) {
    switch (page) {
      case 0:
        return {
          if (!_hasProfile) 'identifier': _fields['identifier'],
          'gender': _fields['gender'],
          'date_of_birth': _fields['date_of_birth'],
          'city': _fields['city'],
          'guardian_name': _fields['guardian_name'],
          'guardian_contact': _fields['guardian_contact'],
        };
      case 1:
        return {
          'guardian_relation': _fields['guardian_relation'],
          'family_type': _fields['family_type'],
          'marital_status': _fields['marital_status'],
          'height': _fields['height'],
          if (_needsFamilyDetails) 'has_children': _fields['has_children'],
          if (_needsFamilyDetails) 'living_situation': _fields['living_situation'],
          if (_needsFamilyDetails && _fields['has_children'] == true) 'children_count': _fields['children_count'],
        };
      case 2:
        return {
          'sect': _fields['sect'],
          'prayer_frequency': _fields['prayer_frequency'],
          'hijab_or_beard': _fields['hijab_or_beard'],
          'diet': _fields['diet'],
          'smokes': _fields['smokes'],
        };
      case 3:
        return {
          'about': _fields['about'],
          'expectations': _fields['expectations'],
          'education': _fields['education'],
          'profession': _fields['profession'],
        };
      default:
        return {};
    }
  }
}

class _StepScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _StepScaffold({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _BasicStep extends StatefulWidget {
  final Map<String, dynamic> fields;
  final bool requireIdentifier;
  const _BasicStep({required this.fields, required this.requireIdentifier});

  @override
  State<_BasicStep> createState() => _BasicStepState();
}

class _BasicStepState extends State<_BasicStep> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _StepScaffold(
      title: l10n.walkInStepBasic,
      children: [
        if (widget.requireIdentifier) ...[
          TextFormField(
            initialValue: widget.fields['identifier'] as String?,
            decoration: InputDecoration(labelText: l10n.walkInIdentifierLabel),
            onChanged: (v) => widget.fields['identifier'] = v,
          ),
          const SizedBox(height: 12),
        ],
        PickerField(
          label: l10n.clientGenderLabel,
          value: widget.fields['gender'] as String?,
          options: const {'male': 'Male', 'female': 'Female'},
          onChanged: (v) => setState(() => widget.fields['gender'] = v),
        ),
        const SizedBox(height: 12),
        _DatePickerField(
          label: l10n.walkInDateOfBirthLabel,
          value: widget.fields['date_of_birth'] as String?,
          onChanged: (v) => setState(() => widget.fields['date_of_birth'] = v),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: widget.fields['city'] as String?,
          decoration: InputDecoration(labelText: l10n.walkInCityLabel),
          onChanged: (v) => widget.fields['city'] = v,
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: widget.fields['guardian_name'] as String?,
          decoration: InputDecoration(labelText: l10n.walkInGuardianNameLabel),
          onChanged: (v) => widget.fields['guardian_name'] = v,
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: widget.fields['guardian_contact'] as String?,
          decoration: InputDecoration(labelText: l10n.walkInGuardianContactLabel),
          onChanged: (v) => widget.fields['guardian_contact'] = v,
        ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String> onChanged;

  const _DatePickerField({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
          firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
          lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
        );
        if (picked != null) {
          onChanged('${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(value ?? ''),
      ),
    );
  }
}

// Heights 4'0" to 7'0", matching the height-range filter the browse
// endpoint supports and the member app's own wizard (nikah_step1_screen.dart).
List<String> _heightOptions() {
  final options = <String>[];
  for (var ft = 4; ft <= 7; ft++) {
    for (var inch = 0; inch <= 11; inch++) {
      if (ft == 7 && inch > 0) break;
      options.add('$ft\'$inch"');
    }
  }
  options.add('Other');
  return options;
}

// Matches web's nikah/wizard/step-family.blade.php $guardianRelOptions
// exactly, plus "Other" as an app-only escape hatch.
const _guardianRelationOptions = ['Self', 'Father', 'Mother', 'Brother', 'Sister', 'Uncle', 'Aunt', 'Grandfather', 'Grandmother', 'Other'];

// Matches web's $familyTypeOptions exactly, plus "Other".
const _familyTypeOptions = ['Joint Family', 'Nuclear Family', 'Living with In-Laws', 'Other'];

const _livingSituations = {
  'alone': 'Alone',
  'with_mother': 'With Mother',
  'with_father': 'With Father',
  'with_maternal_grandparents': 'With Maternal Grandparents',
  'with_paternal_grandparents': 'With Paternal Grandparents',
  'with_children': 'With Their Own Children',
  'other': 'Other',
};

Map<String, String> _identityOptions(List<String> values) => {for (final v in values) v: v};

class _FamilyStep extends StatefulWidget {
  final Map<String, dynamic> fields;
  const _FamilyStep({required this.fields});

  @override
  State<_FamilyStep> createState() => _FamilyStepState();
}

class _FamilyStepState extends State<_FamilyStep> {
  static const _maritalStatuses = {
    'never_married': 'Never Married',
    'divorced': 'Divorced',
    'widowed': 'Widowed',
    'married': 'Married',
    'separated': 'Separated',
  };

  late final _heightOtherController = TextEditingController(text: widget.fields['height'] as String?);
  late final _guardianRelationOtherController = TextEditingController(text: widget.fields['guardian_relation'] as String?);
  late final _familyTypeOtherController = TextEditingController(text: widget.fields['family_type'] as String?);
  late final _childrenCountController = TextEditingController(text: widget.fields['children_count']?.toString());

  // A value already on the profile (e.g. loaded from an existing record)
  // that isn't one of the fixed options still needs to show as "Other"
  // with its real text preserved, rather than silently resetting the field.
  String? _dropdownValueFor(String? raw, List<String> knownOptions) {
    if (raw == null || raw.isEmpty) return null;
    return knownOptions.contains(raw) ? raw : 'Other';
  }

  @override
  void dispose() {
    _heightOtherController.dispose();
    _guardianRelationOtherController.dispose();
    _familyTypeOtherController.dispose();
    _childrenCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final maritalStatus = widget.fields['marital_status'] as String?;
    final needsFamilyDetails = maritalStatus != null && maritalStatus != 'never_married';
    final hasChildren = widget.fields['has_children'] as bool?;
    final heightValue = _dropdownValueFor(widget.fields['height'] as String?, _heightOptions());
    final guardianRelationValue = _dropdownValueFor(widget.fields['guardian_relation'] as String?, _guardianRelationOptions);
    final familyTypeValue = _dropdownValueFor(widget.fields['family_type'] as String?, _familyTypeOptions);

    return _StepScaffold(
      title: l10n.walkInStepFamily,
      children: [
        PickerField(
          label: 'Marital Status',
          value: maritalStatus,
          options: _maritalStatuses,
          onChanged: (v) => setState(() => widget.fields['marital_status'] = v),
        ),
        if (needsFamilyDetails) ...[
          const SizedBox(height: 12),
          PickerField(
            label: 'Do They Have Children?',
            required: true,
            value: hasChildren == null ? null : (hasChildren ? 'yes' : 'no'),
            options: const {'yes': 'Yes', 'no': 'No'},
            onChanged: (v) => setState(() => widget.fields['has_children'] = v == 'yes'),
          ),
          if (hasChildren == true) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _childrenCountController,
              decoration: const InputDecoration(labelText: 'Number of Children'),
              keyboardType: TextInputType.number,
              onChanged: (v) => widget.fields['children_count'] = v,
            ),
          ],
          const SizedBox(height: 12),
          PickerField(
            label: 'Who Do They Currently Live With?',
            required: true,
            value: widget.fields['living_situation'] as String?,
            options: _livingSituations,
            onChanged: (v) => setState(() => widget.fields['living_situation'] = v),
          ),
        ],
        const SizedBox(height: 12),
        PickerField(
          label: 'Guardian Relation',
          value: guardianRelationValue,
          options: _identityOptions(_guardianRelationOptions),
          onChanged: (v) => setState(() => widget.fields['guardian_relation'] = v == 'Other' ? _guardianRelationOtherController.text.trim() : v),
        ),
        if (guardianRelationValue == 'Other') ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _guardianRelationOtherController,
            decoration: const InputDecoration(labelText: 'Enter relation'),
            onChanged: (v) => widget.fields['guardian_relation'] = v,
          ),
        ],
        const SizedBox(height: 12),
        PickerField(
          label: 'Family Type',
          value: familyTypeValue,
          options: _identityOptions(_familyTypeOptions),
          onChanged: (v) => setState(() => widget.fields['family_type'] = v == 'Other' ? _familyTypeOtherController.text.trim() : v),
        ),
        if (familyTypeValue == 'Other') ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _familyTypeOtherController,
            decoration: const InputDecoration(labelText: 'Enter family type'),
            onChanged: (v) => widget.fields['family_type'] = v,
          ),
        ],
        const SizedBox(height: 12),
        PickerField(
          label: 'Height',
          value: heightValue,
          options: _identityOptions(_heightOptions()),
          onChanged: (v) => setState(() => widget.fields['height'] = v == 'Other' ? _heightOtherController.text.trim() : v),
        ),
        if (heightValue == 'Other') ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _heightOtherController,
            decoration: const InputDecoration(labelText: 'Enter height'),
            onChanged: (v) => widget.fields['height'] = v,
          ),
        ],
      ],
    );
  }
}

class _DeenStep extends StatefulWidget {
  final Map<String, dynamic> fields;
  const _DeenStep({required this.fields});

  @override
  State<_DeenStep> createState() => _DeenStepState();
}

class _DeenStepState extends State<_DeenStep> {
  static const _sects = {'Sunni': 'Sunni', 'Shia': 'Shia', 'Ahle Hadith': 'Ahle Hadith', 'Deobandi': 'Deobandi', 'Other': 'Other'};
  static const _prayer = {'always': 'Always', 'usually': 'Usually', 'sometimes': 'Sometimes', 'rarely': 'Rarely'};
  static const _hijabBeard = {'yes': 'Yes', 'no': 'No', 'sometimes': 'Sometimes'};
  static const _diet = {'halal_only': 'Halal Only', 'halal_mostly': 'Mostly Halal', 'no_restriction': 'No Restriction'};
  static const _smokes = {'no': 'No', 'occasionally': 'Occasionally', 'yes': 'Yes'};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _StepScaffold(
      title: l10n.walkInStepDeen,
      children: [
        PickerField(label: 'Sect', value: widget.fields['sect'] as String?, options: _sects, onChanged: (v) => setState(() => widget.fields['sect'] = v)),
        const SizedBox(height: 12),
        PickerField(label: 'Prayer Frequency', value: widget.fields['prayer_frequency'] as String?, options: _prayer, onChanged: (v) => setState(() => widget.fields['prayer_frequency'] = v)),
        const SizedBox(height: 12),
        PickerField(label: 'Hijab / Beard', value: widget.fields['hijab_or_beard'] as String?, options: _hijabBeard, onChanged: (v) => setState(() => widget.fields['hijab_or_beard'] = v)),
        const SizedBox(height: 12),
        PickerField(label: 'Diet', value: widget.fields['diet'] as String?, options: _diet, onChanged: (v) => setState(() => widget.fields['diet'] = v)),
        const SizedBox(height: 12),
        PickerField(label: 'Smokes', value: widget.fields['smokes'] as String?, options: _smokes, onChanged: (v) => setState(() => widget.fields['smokes'] = v)),
      ],
    );
  }
}

// Matches web's nikah/wizard/step-basic.blade.php $educationLevels exactly,
// plus "Other" as an app-only escape hatch.
const _educationOptions = ['Matric / O-Levels', 'Intermediate / A-Levels', "Bachelor's", "Master's", 'MPhil / MS', 'PhD', 'Madrassah / Islamic Education', 'Other'];

class _AboutStep extends StatefulWidget {
  final Map<String, dynamic> fields;
  const _AboutStep({required this.fields});

  @override
  State<_AboutStep> createState() => _AboutStepState();
}

class _AboutStepState extends State<_AboutStep> {
  late final _educationOtherController = TextEditingController(text: widget.fields['education'] as String?);

  @override
  void dispose() {
    _educationOtherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rawEducation = widget.fields['education'] as String?;
    final educationValue = (rawEducation == null || rawEducation.isEmpty)
        ? null
        : (_educationOptions.contains(rawEducation) ? rawEducation : 'Other');

    return _StepScaffold(
      title: l10n.walkInStepAbout,
      children: [
        PickerField(
          label: 'Education',
          value: educationValue,
          options: _identityOptions(_educationOptions),
          onChanged: (v) => setState(() => widget.fields['education'] = v == 'Other' ? _educationOtherController.text.trim() : v),
        ),
        if (educationValue == 'Other') ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _educationOtherController,
            decoration: const InputDecoration(labelText: 'Enter education'),
            onChanged: (v) => widget.fields['education'] = v,
          ),
        ],
        const SizedBox(height: 12),
        TextFormField(initialValue: widget.fields['profession'] as String?, decoration: const InputDecoration(labelText: 'Profession'), onChanged: (v) => widget.fields['profession'] = v),
        const SizedBox(height: 12),
        TextFormField(initialValue: widget.fields['about'] as String?, decoration: const InputDecoration(labelText: 'About'), maxLines: 3, onChanged: (v) => widget.fields['about'] = v),
        const SizedBox(height: 12),
        TextFormField(initialValue: widget.fields['expectations'] as String?, decoration: const InputDecoration(labelText: 'Expectations'), maxLines: 3, onChanged: (v) => widget.fields['expectations'] = v),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
          child: Text(
            "🔗 CNIC and photo aren't collected here — after payment, you'll land on the client's page where you can set their login password and share their secure self-upload link.",
            style: TextStyle(color: Colors.blue.shade900, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  final String label;
  final bool hasImage;
  final VoidCallback onTap;
  const _ImagePickerTile({required this.label, required this.hasImage, required this.onTap});

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

// Reached only after the wizard's Verification step; the profile must
// already exist by then (payment/store() requires it). Kept as the
// wizard's final page for a linear flow, but posts to a separate endpoint.
class _PaymentStep extends ConsumerStatefulWidget {
  final int leadId;
  const _PaymentStep({required this.leadId});

  @override
  ConsumerState<_PaymentStep> createState() => _PaymentStepState();
}

class _PaymentStepState extends ConsumerState<_PaymentStep> {
  String _method = 'jazzcash';
  final _referenceController = TextEditingController();
  File? _screenshot;
  bool _submitting = false;
  String? _error;
  bool _submitted = false;
  final _picker = ImagePicker();

  // Gallery, not camera — a payment screenshot already exists as an image
  // (from JazzCash/the bank app), it's never something to photograph live.
  // Camera-only stays reserved for genuine identity verification (a selfie,
  // or a physical document photographed on the spot) — see apply_screen.dart.
  Future<void> _pickScreenshot() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => _screenshot = File(picked.path));
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_screenshot == null) {
      setState(() => _error = l10n.errorGeneric);
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

    if (_submitted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 56),
              const SizedBox(height: 12),
              Text(l10n.walkInFinish, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                l10n.loginPasswordExplain,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.password),
                label: Text(l10n.loginPasswordSet),
                onPressed: () => showSetLoginPasswordFlow(context, ref, widget.leadId),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          ),
        ),
      );
    }

    return _StepScaffold(
      title: l10n.walkInStepPayment,
      children: [
        if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(_error!, style: const TextStyle(color: Colors.redAccent))),
        PickerField(
          label: l10n.walkInPaymentMethodLabel,
          value: _method,
          options: const {'jazzcash': 'JazzCash', 'bank_transfer': 'Bank Transfer', 'cash': 'Cash', 'whatsapp': 'WhatsApp'},
          onChanged: (v) => setState(() => _method = v ?? 'jazzcash'),
        ),
        const SizedBox(height: 12),
        TextFormField(controller: _referenceController, decoration: InputDecoration(labelText: l10n.walkInPaymentReferenceLabel)),
        const SizedBox(height: 12),
        _ImagePickerTile(label: l10n.walkInPaymentScreenshotLabel, hasImage: _screenshot != null, onTap: _pickScreenshot),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(l10n.walkInSubmitPayment),
        ),
      ],
    );
  }
}
