import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/picker_field.dart';
import '../../state/client_detail_provider.dart';
import '../client_list_screen.dart';

// Mirrors the admin/web Nikah profile wizard's own "Partner Preferences"
// section (resources/views/admin/nikah/wizard/step-about.blade.php) field
// for field — min/max age, city, sect, education, marital status, income,
// other — all optional, same as there. Saved through the same
// MatchmakingRequirementItem rows the backend's match-scoring already
// knows how to read (saveRequirement()), just with this smaller, simpler
// field set instead of every type in MatchmakingRequirementItem::TYPES.
class RequirementsTab extends ConsumerStatefulWidget {
  final int leadId;
  final Map<String, dynamic> client;
  const RequirementsTab({super.key, required this.leadId, required this.client});

  @override
  ConsumerState<RequirementsTab> createState() => _RequirementsTabState();
}

class _RequirementsTabState extends ConsumerState<RequirementsTab> {
  late final TextEditingController _minAgeController;
  late final TextEditingController _maxAgeController;
  late final TextEditingController _cityController;
  late final TextEditingController _incomeController;
  late final TextEditingController _otherController;
  String? _sect;
  String? _education;
  String? _maritalStatus;
  bool _saving = false;
  String? _error;

  static const _sects = {'Sunni': 'Sunni', 'Shia': 'Shia', 'Ahle Hadith': 'Ahle Hadith', 'Deobandi': 'Deobandi', 'Other': 'Other'};
  static const _educationLevels = {
    'Matric / O-Levels': 'Matric / O-Levels',
    'Intermediate / A-Levels': 'Intermediate / A-Levels',
    "Bachelor's": "Bachelor's",
    "Master's": "Master's",
    'MPhil / MS': 'MPhil / MS',
    'PhD': 'PhD',
    'Madrassah / Islamic Education': 'Madrassah / Islamic Education',
  };
  static const _maritalStatuses = {
    'never_married': 'Never Married',
    'divorced': 'Divorced',
    'widowed': 'Widowed',
    'separated': 'Separated',
    'married': 'Married',
  };

  @override
  void initState() {
    super.initState();
    final requirement = widget.client['requirement'] as Map?;
    final items = requirement != null
        ? List<Map<String, dynamic>>.from((requirement['items'] as List).map((e) => Map<String, dynamic>.from(e as Map)))
        : <Map<String, dynamic>>[];
    final values = {for (final item in items) item['requirement_type'] as String: item['requirement_value'] as String};

    final ageRange = _parseAgeRange(values['age_range']);
    _minAgeController = TextEditingController(text: ageRange.$1?.toString() ?? '');
    _maxAgeController = TextEditingController(text: ageRange.$2?.toString() ?? '');
    _cityController = TextEditingController(text: values['city'] ?? '');
    _incomeController = TextEditingController(text: values['income_range'] ?? '');
    _otherController = TextEditingController(text: values['other'] ?? '');
    _sect = _sects.containsKey(values['sect']) ? values['sect'] : null;
    _education = _educationLevels.containsKey(values['education']) ? values['education'] : null;
    _maritalStatus = _maritalStatuses.containsKey(values['marital_status']) ? values['marital_status'] : null;
  }

  // "25-30" / "25 to 30" -> (25, 30); a single "25" -> (25, null) — mirrors
  // the backend's own MatchmakingRequirementItem::ageMatches() parsing, so
  // a value saved by the web admin form (or a previous version of this
  // screen) round-trips back into these fields correctly.
  (int?, int?) _parseAgeRange(String? value) {
    if (value == null || value.trim().isEmpty) return (null, null);
    final numbers = RegExp(r'\d+').allMatches(value).map((m) => int.parse(m.group(0)!)).toList();
    if (numbers.isEmpty) return (null, null);
    if (numbers.length == 1) return (numbers[0], null);
    return (numbers[0] < numbers[1] ? numbers[0] : numbers[1], numbers[0] < numbers[1] ? numbers[1] : numbers[0]);
  }

  @override
  void dispose() {
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _cityController.dispose();
    _incomeController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final minAge = _minAgeController.text.trim();
      final maxAge = _maxAgeController.text.trim();
      String? ageRange;
      if (minAge.isNotEmpty && maxAge.isNotEmpty) {
        ageRange = '$minAge-$maxAge';
      } else if (minAge.isNotEmpty) {
        ageRange = '$minAge+';
      } else if (maxAge.isNotEmpty) {
        ageRange = '0-$maxAge';
      }

      final values = <String, String?>{
        'age_range': ageRange,
        'city': _cityController.text.trim(),
        'sect': _sect,
        'education': _education,
        'marital_status': _maritalStatus,
        'income_range': _incomeController.text.trim(),
        'other': _otherController.text.trim(),
      };

      final items = values.entries
          .where((e) => (e.value ?? '').trim().isNotEmpty)
          .map((e) => {'requirement_type': e.key, 'requirement_value': e.value!.trim(), 'priority': 'preferred'})
          .toList();

      await ref.read(clientRepositoryProvider).saveRequirement(widget.leadId, notes: null, items: items);
      ref.invalidate(clientDetailProvider(widget.leadId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.requirementsSaved)));
      }
    } on ApiException catch (e) {
      setState(() => _error = e.displayMessage);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        InlineErrorBanner(message: _error),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minAgeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Minimum Age'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxAgeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Maximum Age'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _cityController, decoration: const InputDecoration(labelText: 'Preferred City')),
              const SizedBox(height: 12),
              PickerField(label: 'Preferred Sect', value: _sect, options: _sects, onChanged: (v) => setState(() => _sect = v)),
              const SizedBox(height: 12),
              PickerField(label: 'Preferred Education', value: _education, options: _educationLevels, onChanged: (v) => setState(() => _education = v)),
              const SizedBox(height: 12),
              PickerField(label: 'Preferred Marital Status', value: _maritalStatus, options: _maritalStatuses, onChanged: (v) => setState(() => _maritalStatus = v)),
              const SizedBox(height: 12),
              TextFormField(controller: _incomeController, decoration: const InputDecoration(labelText: 'Preferred Income / Business Worth')),
              const SizedBox(height: 12),
              TextFormField(controller: _otherController, maxLines: 2, decoration: const InputDecoration(labelText: 'Other Preferences')),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l10n.clientSave),
          ),
        ),
      ],
    );
  }
}
