import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../features/clients/presentation/client_list_screen.dart';
import '../../l10n/generated/app_localizations.dart';

// Shared by the client Overview tab and the walk-in wizard's payment-success
// screen — the counselor may want to set a client's login password from
// either place, so this owns the whole show-dialog → call-API → snackbar
// flow in one reusable function rather than duplicating it.
Future<void> showSetLoginPasswordFlow(BuildContext context, WidgetRef ref, int leadId) async {
  final l10n = AppLocalizations.of(context)!;
  final password = await showDialog<String>(
    context: context,
    builder: (context) => _SetPasswordDialog(l10n: l10n),
  );
  if (password == null || !context.mounted) return;

  try {
    await ref.read(clientRepositoryProvider).setLoginPassword(leadId, password);
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.loginPasswordSuccess)));
  } on ApiException catch (e) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.displayMessage)));
  }
}

class _SetPasswordDialog extends StatefulWidget {
  final AppLocalizations l10n;
  const _SetPasswordDialog({required this.l10n});

  @override
  State<_SetPasswordDialog> createState() => _SetPasswordDialogState();
}

class _SetPasswordDialogState extends State<_SetPasswordDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Excludes visually ambiguous characters (0/O, 1/l/I) since this gets
  // read aloud or copy-pasted by hand to a client who may not be tech-savvy.
  void _generate() {
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789';
    final random = Random.secure();
    final value = List.generate(10, (_) => chars[random.nextInt(chars.length)]).join();
    setState(() => _controller.text = value);
  }

  Future<void> _copy() async {
    if (_controller.text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _controller.text));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.l10n.loginPasswordCopied)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n.loginPasswordTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.loginPasswordExplain, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l10n.loginPasswordFieldLabel,
              suffixIcon: IconButton(icon: const Icon(Icons.copy, size: 20), tooltip: l10n.loginPasswordCopyButton, onPressed: _copy),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.autorenew, size: 18),
            label: Text(l10n.loginPasswordGenerateButton),
            onPressed: _generate,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(MaterialLocalizations.of(context).cancelButtonLabel)),
        FilledButton(
          onPressed: _controller.text.trim().length < 8 ? null : () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(l10n.loginPasswordConfirmButton),
        ),
      ],
    );
  }
}
