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

// Replaces the old free-form "add any number of rows" Requirements tab with
// a guided, step-by-step wizard over the exact same fixed set of
// requirement types the backend's match-scoring already knows how to
// compare against a real candidate (MatchmakingRequirementItem::TYPES /
// matchesCandidate()) — same storage, same save endpoint, just a UI that
// walks a counselor through every known criterion once instead of leaving
// them to remember which ones exist and add each as its own freeform row.
class RegistrationTab extends ConsumerStatefulWidget {
  final int leadId;
  final Map<String, dynamic> client;
  const RegistrationTab({super.key, required this.leadId, required this.client});

  @override
  ConsumerState<RegistrationTab> createState() => _RegistrationTabState();
}

class _RegistrationTabState extends ConsumerState<RegistrationTab> {
  final _pageController = PageController();
  int _page = 0;
  late final Map<String, String> _values;
  late final TextEditingController _notesController;
  bool _saving = false;
  String? _error;

  // Only these three are hard requirements for a usable shortlist search —
  // everything else refines it further but isn't essential to have on day
  // one. Grouped the same way the client's own Nikah-profile wizard groups
  // its fields (basic criteria, then background/deen, then everything
  // else), for a counselor already familiar with that shape.
  static const _requiredTypes = {'age_range', 'city', 'marital_status'};
  static const _basicTypes = ['age_range', 'city', 'country', 'marital_status', 'height'];
  static const _deenTypes = ['sect', 'religious_practice', 'hijab_or_beard', 'family_type', 'education', 'profession'];
  static const _otherTypes = ['income_range', 'mother_tongue', 'children_preference', 'relocation', 'marriage_timeline', 'family_expectations', 'other'];

  // Small, fixed option sets with no dedicated enums endpoint of their own
  // (unlike marital_status/qualification elsewhere) — mirrors the exact
  // same values walk_in_wizard_screen.dart's own _FamilyStep/_DeenStep use,
  // kept local here the same way those are, rather than a shared constant
  // neither screen currently has.
  static const _maritalStatuses = {
    'never_married': 'Never Married',
    'divorced': 'Divorced',
    'widowed': 'Widowed',
    'married': 'Married',
    'separated': 'Separated',
  };
  static const _sects = {'Sunni': 'Sunni', 'Shia': 'Shia', 'Ahle Hadith': 'Ahle Hadith', 'Deobandi': 'Deobandi', 'Other': 'Other'};

  @override
  void initState() {
    super.initState();
    final requirement = widget.client['requirement'] as Map?;
    final items = requirement != null
        ? List<Map<String, dynamic>>.from((requirement['items'] as List).map((e) => Map<String, dynamic>.from(e as Map)))
        : <Map<String, dynamic>>[];
    _values = {for (final item in items) item['requirement_type'] as String: item['requirement_value'] as String};
    _notesController = TextEditingController(text: requirement?['notes'] as String? ?? '');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _validateStep(int page) {
    if (page == 0) {
      for (final type in _requiredTypes) {
        if ((_values[type] ?? '').trim().isEmpty) return AppLocalizations.of(context)!.registrationRequiredFieldsMissing;
      }
    }
    return null;
  }

  Future<void> _next() async {
    final error = _validateStep(_page);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() => _error = null);
    await _pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  Future<void> _back() async {
    await _pageController.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  Future<void> _save() async {
    final error = _validateStep(0);
    if (error != null) {
      setState(() {
        _error = error;
        _page = 0;
      });
      _pageController.jumpToPage(0);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final items = _values.entries
          .where((e) => e.value.trim().isNotEmpty)
          .map((e) => {
                'requirement_type': e.key,
                'requirement_value': e.value.trim(),
                // Auto-assigned rather than a manual picker per row — the
                // three required fields matter most to a shortlist search,
                // everything else is a soft refinement. Simpler than asking
                // a counselor to also judge each field's priority by hand.
                'priority': _requiredTypes.contains(e.key) ? 'must_have' : 'preferred',
              })
          .toList();

      await ref.read(clientRepositoryProvider).saveRequirement(
            widget.leadId,
            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
            items: items,
          );
      ref.invalidate(clientDetailProvider(widget.leadId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.registrationSaved)));
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
    final enumsAsync = ref.watch(enumsProvider);
    final isLastPage = _page == 2;

    return AsyncValueView(
      loading: enumsAsync.isLoading,
      error: enumsAsync.error,
      data: enumsAsync.value,
      builder: (enums) => Column(
        children: [
          InlineErrorBanner(message: _error),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (p) => setState(() => _page = p),
              children: [
                _Step(title: l10n.registrationStepBasic, children: _basicTypes.map((t) => _fieldFor(context, t, enums)).toList()),
                _Step(title: l10n.registrationStepDeen, children: _deenTypes.map((t) => _fieldFor(context, t, enums)).toList()),
                _Step(
                  title: l10n.registrationStepOther,
                  children: [
                    ..._otherTypes.map((t) => _fieldFor(context, t, enums)),
                    const SizedBox(height: 4),
                    TextField(controller: _notesController, decoration: InputDecoration(labelText: l10n.clientNotesLabel), maxLines: 3),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_page > 0) Expanded(child: OutlinedButton(onPressed: _saving ? null : _back, child: Text(l10n.registrationBack))),
                if (_page > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : (isLastPage ? _save : _next),
                    style: ElevatedButton.styleFrom(backgroundColor: MatchmakerTheme.plum),
                    child: _saving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(isLastPage ? l10n.clientSave : l10n.registrationNext),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldFor(BuildContext context, String type, MatchmakerEnums enums) {
    final label = enums.requirementTypes[type] ?? type;
    final required = _requiredTypes.contains(type);

    if (type == 'marital_status') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: PickerField(
          label: label,
          value: _maritalStatuses.containsKey(_values[type]) ? _values[type] : null,
          options: _maritalStatuses,
          required: required,
          onChanged: (v) => setState(() => _values[type] = v ?? ''),
        ),
      );
    }

    if (type == 'sect') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: PickerField(
          label: label,
          value: _sects.containsKey(_values[type]) ? _values[type] : null,
          options: _sects,
          required: required,
          onChanged: (v) => setState(() => _values[type] = v ?? ''),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: _values[type],
        decoration: InputDecoration(
          label: requiredFieldLabel(context, label, required),
          labelText: required ? null : label,
          hintText: type == 'age_range' ? AppLocalizations.of(context)!.registrationAgeRangeHint : null,
        ),
        onChanged: (v) => _values[type] = v,
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Step({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
