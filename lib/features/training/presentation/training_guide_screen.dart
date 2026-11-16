import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/locale_controller.dart';
import '../../../core/theme/matchmaker_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/guide_section_card.dart';
import '../domain/training_guide_content.dart';

class TrainingGuideScreen extends ConsumerWidget {
  const TrainingGuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = ref.watch(localeControllerProvider)?.languageCode ?? 'en';
    final sections = TrainingGuideContent.forLocale(languageCode);
    final isRtl = languageCode == 'ur';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trainingGuideTitle)),
      body: Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                itemCount: sections.length,
                itemBuilder: (context, index) => GuideSectionCard(title: sections[index].title, paragraphs: sections[index].paragraphs),
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
                    onPressed: () => context.push('/training-quiz'),
                    child: Text(l10n.trainingGuideTakeAssessment, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
