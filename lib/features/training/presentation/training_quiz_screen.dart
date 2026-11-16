import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/state/locale_controller.dart';
import '../../../core/theme/matchmaker_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../auth/state/auth_controller.dart';
import '../data/training_repository.dart';

final trainingRepositoryProvider = Provider((ref) => TrainingRepository(ref.watch(apiClientProvider)));

final trainingQuizQuestionsProvider = FutureProvider.autoDispose((ref) => ref.watch(trainingRepositoryProvider).questions());

final trainingQuizAttemptsProvider = FutureProvider.autoDispose((ref) => ref.watch(trainingRepositoryProvider).attempts());

class TrainingQuizScreen extends ConsumerStatefulWidget {
  const TrainingQuizScreen({super.key});

  @override
  ConsumerState<TrainingQuizScreen> createState() => _TrainingQuizScreenState();
}

class _TrainingQuizScreenState extends ConsumerState<TrainingQuizScreen> {
  final Map<int, int> _answers = {};
  bool _submitting = false;
  Map<String, dynamic>? _result;

  Future<void> _submit(List<Map<String, dynamic>> questions) async {
    setState(() => _submitting = true);
    try {
      final payload = _answers.entries.map((e) => {'question_id': e.key, 'selected_index': e.value}).toList();
      final result = await ref.read(trainingRepositoryProvider).submit(payload);
      if (mounted) {
        setState(() => _result = result);
        ref.invalidate(trainingQuizAttemptsProvider);
        // Refresh the authenticated user so a passing/promoting submit
        // unlocks Requirements/Consent/Browse immediately, without needing
        // a full logout/login.
        await ref.read(authControllerProvider.notifier).refreshUser();
      }
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.displayMessage)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _retake() {
    setState(() {
      _answers.clear();
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = ref.watch(localeControllerProvider)?.languageCode ?? 'en';
    final isUrdu = languageCode == 'ur';
    final async = ref.watch(trainingQuizQuestionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trainingQuizTitle)),
      body: AsyncValueView(
        loading: async.isLoading,
        error: async.error,
        data: async.valueOrNull,
        onRetry: () => ref.invalidate(trainingQuizQuestionsProvider),
        builder: (questions) {
          if (_result != null) {
            final score = _result!['score'] as int;
            final total = _result!['total'] as int;
            final passed = _result!['passed'] as bool;
            final promoted = _result!['promoted'] as bool? ?? false;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(passed ? '🎉' : '📘', style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(l10n.trainingQuizScoreResult(score, total), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(
                      promoted ? l10n.trainingQuizPromoted : (passed ? l10n.trainingQuizPassed : l10n.trainingQuizFailed),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: passed ? Colors.green.shade700 : Colors.grey.shade700),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton(onPressed: _retake, child: Text(l10n.trainingQuizRetake)),
                  ],
                ),
              ),
            );
          }

          final allAnswered = questions.isNotEmpty && questions.every((q) => _answers.containsKey(q['id'] as int));

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    final questionId = q['id'] as int;
                    final options = List<Map<String, dynamic>>.from((q['options'] as List).map((e) => Map<String, dynamic>.from(e as Map)));

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ${isUrdu ? q['question_ur'] : q['question_en']}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                            ),
                            const SizedBox(height: 8),
                            for (final option in options)
                              RadioListTile<int>(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                activeColor: MatchmakerTheme.plum,
                                title: Text(isUrdu ? option['text_ur'] as String : option['text_en'] as String),
                                value: option['index'] as int,
                                groupValue: _answers[questionId],
                                onChanged: (value) => setState(() => _answers[questionId] = value!),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: MatchmakerTheme.plum, padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: (!allAnswered || _submitting) ? null : () => _submit(questions),
                      child: _submitting
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(l10n.trainingQuizSubmit, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
