import 'package:flutter/material.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/matchmaker_theme.dart';
import '../../l10n/generated/app_localizations.dart';

// Standing project rule: every API call shows loading/success/error state,
// never fails silently. One small widget used everywhere a screen loads
// data from the backend, so that rule is structural, not a habit to
// remember on every screen.
class AsyncValueView<T> extends StatelessWidget {
  final bool loading;
  final Object? error;
  final T? data;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;

  const AsyncValueView({
    super.key,
    required this.loading,
    required this.error,
    required this.data,
    required this.builder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (loading && data == null) {
      return const Center(child: CircularProgressIndicator(color: MatchmakerTheme.plum));
    }

    if (error != null && data == null) {
      final message = error is ApiException ? (error as ApiException).displayMessage : l10n.errorGeneric;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                OutlinedButton(onPressed: onRetry, child: Text(l10n.retry)),
              ],
            ],
          ),
        ),
      );
    }

    if (data == null) {
      return const SizedBox.shrink();
    }

    return builder(data as T);
  }
}

// Small inline banner for form-submission errors — used on every screen
// with a form so validation/API failures are always visible, never silent.
class InlineErrorBanner extends StatelessWidget {
  final String? message;
  const InlineErrorBanner({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(message!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
    );
  }
}

class InlineStatusBanner extends StatelessWidget {
  final String? message;
  const InlineStatusBanner({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Text(message!, style: TextStyle(color: Colors.green.shade700, fontSize: 13)),
    );
  }
}
