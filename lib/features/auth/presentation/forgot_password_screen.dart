import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/password_field.dart';
import '../state/auth_controller.dart';

// Mirrors the member app's forgot-password screen — same two-step flow on one
// screen, same endpoints — differing only in this app's chrome and in
// rejecting a non-counselor account the way login does.
//
// Counselors are handed a password by admin at certification, so "I've lost
// the one I was given" is the common case here, not an edge case.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _codeSent = false;
  bool _submitting = false;
  String? _error;
  String? _notice;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String get _email => _emailController.text.trim();

  Future<void> _sendCode() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_emailFormKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _error = null;
      _notice = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).forgotPassword(_email);
      if (!mounted) return;
      setState(() {
        _codeSent = true;
        _notice = l10n.resetCodeSentTo(_email);
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.displayMessage);
    } catch (_) {
      if (mounted) setState(() => _error = l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _reset() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_resetFormKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).resetPassword(
            email: _email,
            code: _codeController.text.trim(),
            password: _passwordController.text,
          );
      // The router's redirect takes an authenticated counselor to the
      // dashboard on its own.
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message == 'not_counselor_account'
            ? l10n.notCounselorAccount
            : e.firstErrorFor('code') ?? e.firstErrorFor('password') ?? e.displayMessage;
      });
    } catch (_) {
      if (mounted) setState(() => _error = l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.forgotPasswordTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Image.asset('assets/icon.png', width: 72)),
                const SizedBox(height: 18),
                Text(
                  l10n.forgotPasswordIntro,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, height: 1.4),
                ),
                const SizedBox(height: 20),
                InlineErrorBanner(message: _error),
                if (_notice != null) InlineStatusBanner(message: _notice),
                if (!_codeSent) _emailStep(l10n) else _resetStep(l10n),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _submitting ? null : () => context.go('/login'),
                  child: Text(l10n.backToLogin),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailStep(AppLocalizations l10n) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: l10n.emailOrPhone),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: (v) {
              final value = (v ?? '').trim();
              if (value.isEmpty) return l10n.fieldRequired;
              if (!value.contains('@') || !value.contains('.')) return l10n.invalidEmail;
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitting ? null : _sendCode,
            child: _submitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l10n.sendResetCode),
          ),
        ],
      ),
    );
  }

  Widget _resetStep(AppLocalizations l10n) {
    return Form(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _codeController,
            decoration: InputDecoration(labelText: l10n.resetCode, counterText: ''),
            keyboardType: TextInputType.number,
            maxLength: 6,
            validator: (v) => (v ?? '').trim().length != 6 ? l10n.fieldRequired : null,
          ),
          const SizedBox(height: 12),
          PasswordField(
            controller: _passwordController,
            labelText: l10n.newPassword,
            autofillHints: const [AutofillHints.newPassword],
            validator: (v) {
              if ((v ?? '').isEmpty) return l10n.fieldRequired;
              // Mirrors Laravel's Password::defaults() minimum, so an
              // obviously-too-short password is caught before the round trip.
              if (v!.length < 8) return l10n.passwordTooShort;
              return null;
            },
          ),
          const SizedBox(height: 12),
          PasswordField(
            controller: _confirmController,
            labelText: l10n.confirmPassword,
            autofillHints: const [AutofillHints.newPassword],
            validator: (v) => v != _passwordController.text ? l10n.passwordsDoNotMatch : null,
            onFieldSubmitted: (_) => _reset(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitting ? null : _reset,
            child: _submitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l10n.resetPasswordButton),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _submitting
                    ? null
                    : () => setState(() {
                          _codeSent = false;
                          _notice = null;
                          _error = null;
                          _codeController.clear();
                        }),
                child: Text(l10n.useADifferentEmail),
              ),
              TextButton(
                onPressed: _submitting ? null : _sendCode,
                child: Text(l10n.resendCode),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
