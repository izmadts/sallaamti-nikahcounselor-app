import 'package:flutter/material.dart';

// Every enumerable field in the app (consent type, lead status/source, etc.)
// renders as a dropdown sourced from the backend's own enum arrays
// (GET /matchmaker/meta/enums) rather than free text — standing project
// convention (feedback_prefer_select_inputs_big_forms).
class PickerField extends StatelessWidget {
  final String label;
  final String? value;
  final Map<String, String> options;
  final ValueChanged<String?> onChanged;
  final String? helperText;
  final bool required;

  const PickerField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.helperText,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        helperText: helperText,
        helperMaxLines: 3,
      ),
      items: options.entries
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis)))
          .toList(),
      onChanged: onChanged,
      validator: required ? (v) => v == null ? 'Required' : null : null,
    );
  }
}

// A "?" hover/tap tooltip for fields whose meaning isn't obvious at a
// glance — matches the web app's helping-tip pass on the matchmaker forms.
class HelpTip extends StatelessWidget {
  final String message;
  const HelpTip({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      triggerMode: TooltipTriggerMode.tap,
      child: const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Icon(Icons.help_outline, size: 16, color: Colors.grey),
      ),
    );
  }
}
